{
  config,
  pkgs,
  ...
}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/tuliprox/config 0755 root root -"
    "d /var/lib/tuliprox/data 0755 root root -"
    "d /var/lib/tuliprox/backup 0755 root root -"
  ];

  sops.templates."tuliprox-source" = {
    content = ''
      templates:
        # Live channels format: EN| or NL| or A|
        - name: NL_LIVE
          value: '^NL\|.*'
        - name: EN_LIVE
          value: '^EN\|.*'
        - name: A_LIVE
          value: '^A\|.*'

        # VOD/Series format: NL - or EN - or A -
        - name: NL_VOD
          value: '^NL\s-\s.*'
        - name: EN_VOD
          value: '^EN\s-\s.*'
        - name: A_VOD
          value: '^A\s-\s.*'

        - name: ADULT_CONTENT
          value: '(?i).*(XXX|Adult|18\+).*'

        # Combined filters
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
              url: "${config.sops.placeholder."tuliprox/url"}"
              username: "${config.sops.placeholder."tuliprox/username"}"
              password: "${config.sops.placeholder."tuliprox/password"}"
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
    '';
    path = "/var/lib/tuliprox/config/source.yml";
  };

  sops.templates."tuliprox-config" = {
    content = ''
      api:
        host: 0.0.0.0
        port: 8080
        web_root: ./web
      working_dir: ./data
      # Update on startup
      update_on_boot: false  # Changed to false - only update on schedule

      # Update EPG twice daily (morning and evening)
      schedules:
          - schedule: "0 0 6 * * * *"   # 6 AM
            targets:
              - filtered_iptv
          - schedule: "0 0 18 * * * *"  # 6 PM
            targets:
              - filtered_iptv
    '';
    path = "/var/lib/tuliprox/config/config.yml";
  };

  sops.templates."tuliprox-api-proxy" = {
    content = ''
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
    '';
    path = "/var/lib/tuliprox/config/api-proxy.yml";
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
                  hostPath.path = "/var/lib/tuliprox/config";
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
