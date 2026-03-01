{
  config,
  pkgs,
  ...
}: {
  sops.secrets."tuliprox/url" = {};
  sops.secrets."tuliprox/username" = {};
  sops.secrets."tuliprox/password" = {};

  systemd.tmpfiles.rules = [
    "d /var/lib/tuliprox/config 0755 root root -"
    "d /var/lib/tuliprox/data 0755 root root -"
    "d /var/lib/tuliprox/backup 0755 root root -"
  ];

  # Create a systemd service to generate config files from secrets
  systemd.services.tuliprox-config-generator = {
    description = "Generate tuliprox config files";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Read secrets
      URL=$(cat /run/secrets/tuliprox/url)
      USERNAME=$(cat /run/secrets/tuliprox/username)
      PASSWORD=$(cat /run/secrets/tuliprox/password)

      # Generate source.yml
      cat > /var/lib/tuliprox/config/source.yml << 'EOF'
      templates:
        - name: NL_LIVE
          value: '^NL\|.*'
        - name: EN_LIVE
          value: '^EN\|.*'
        - name: A_LIVE
          value: '^A\|.*'
        - name: NL_VOD
          value: '^NL\s-\s.*'
        - name: EN_VOD
          value: '^EN\s-\s.*'
        - name: A_VOD
          value: '^A\s-\s.*'
        - name: ADULT_CONTENT
          value: '(?i).*(XXX|Adult|18\+).*'
        - name: NL_ALL
          value: '(Title ~ "!NL_LIVE!" OR Title ~ "!NL_VOD!")'
        - name: EN_ALL
          value: '(Title ~ "!EN_LIVE!" OR Title ~ "!EN_VOD!")'
        - name: A_ALL
          value: '(Title ~ "!A_LIVE!" OR Title ~ "!A_VOD!")'
      sources:
        - inputs:
            - name: darktv
              type: xtream
              url: "$URL"
              username: "$USERNAME"
              password: "$PASSWORD"
              persist: "./playlist_"
              epg:
                sources:
                  - url: "http://epg.darktv-pro.cc/xmltv.php?username=89a0837da0&password=1537d53cd78e"
                    priority: 0
                    logo_override: false
                smart_match:
                  enabled: true
                  fuzzy_matching: true
                  match_threshold: 80
                  best_match_threshold: 95
              options:
                xtream_skip_live: false
                xtream_skip_vod: false
                xtream_skip_series: false
          targets:
            - name: filtered_iptv
              output:
                - type: xtream
                  skip_live_direct_source: true
                  skip_video_direct_source: true
                  skip_series_direct_source: true
              filter: "(!NL_ALL! OR !EN_ALL! OR !A_ALL!) AND NOT(Title ~ \"!ADULT_CONTENT!\")"
              sort:
                match_as_ascii: true
                groups:
                  order: asc
      EOF

      # Generate config.yml
      cat > /var/lib/tuliprox/config/config.yml << 'EOF'
      api:
        host: 0.0.0.0
        port: 8080
        web_root: ./web
      working_dir: ./data
      update_on_boot: false
      schedules:
          - schedule: "0 0 6 * * * *"
            targets:
              - filtered_iptv
          - schedule: "0 0 18 * * * *"
            targets:
              - filtered_iptv
      EOF

      # Generate api-proxy.yml
      cat > /var/lib/tuliprox/config/api-proxy.yml << 'EOF'
      server:
        - name: default
          protocol: https
          host: iptv.krugten.org
          port: '443'
          timezone: Europe/Amsterdam
          message: Welcome to tuliprox
      user:
        - target: filtered_iptv
          credentials:
            - username: local
              password: local123
              proxy: redirect
              server: default
      EOF

      chmod 644 /var/lib/tuliprox/config/*.yml
    '';
  };

  services.k3s.manifests.tuliprox = {
    enable = true;
    content = [
      {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "tuliprox";
          namespace = "tuliprox";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "tuliprox";
          template = {
            metadata.labels.app = "tuliprox";
            spec = {
              containers = [
                {
                  name = "tuliprox";
                  image = "ghcr.io/euzu/tuliprox:latest";
                  command = ["/app/tuliprox"];
                  args = ["-s" "-p" "/app/config"];
                  ports = [{containerPort = 8080;}];
                  volumeMounts = [
                    {
                      name = "config";
                      mountPath = "/app/config";
                    }
                    {
                      name = "secrets";
                      mountPath = "/run/secrets/rendered";
                    }
                    {
                      name = "data";
                      mountPath = "/app/data";
                    }
                    {
                      name = "backup";
                      mountPath = "/app/backup";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  hostPath.path = "/run/secrets/rendered";
                }
                {
                  name = "secrets";
                  hostPath.path = "/run/secrets/rendered";
                }
                {
                  name = "data";
                  hostPath.path = "/var/lib/tuliprox/data";
                }
                {
                  name = "backup";
                  hostPath.path = "/var/lib/tuliprox/backup";
                }
              ];
            };
          };
        };
      }
      {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "tuliprox";
          namespace = "tuliprox";
        };
        spec = {
          selector.app = "tuliprox";
          ports = [
            {
              port = 8080;
              targetPort = 8080;
            }
          ];
        };
      }
      {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "tuliprox";
          namespace = "tuliprox";
          annotations = {
            "kubernetes.io/ingress.class" = "nginx";
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
            "nginx.ingress.kubernetes.io/proxy-buffering" = "off";
            "nginx.ingress.kubernetes.io/proxy-request-buffering" = "off";
          };
        };
        spec = {
          tls = [
            {
              hosts = ["iptv.krugten.org"];
              secretName = "tuliprox-tls";
            }
          ];
          rules = [
            {
              host = "iptv.krugten.org";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "tuliprox";
                    port.number = 8080;
                  };
                }
              ];
            }
          ];
        };
      }
    ];
  };
}
