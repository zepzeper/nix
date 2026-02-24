{
  config,
  pkgs,
  ...
}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/homepage 0755 root root -"
  ];

  sops.templates."homepage-settings" = {
    content = ''
      title: Krugten Home
      theme: dark
      color: slate
      headerStyle: clean
      layout:
        Services:
          style: row
          columns: 4
    '';
    path = "/var/lib/homepage/settings.yaml";
  };

  sops.templates."homepage-services" = {
    content = ''
      - Services:
          - Home Assistant:
              href: https://homeassistant.krugten.org
              description: Home Automation
              icon: home-assistant.png
          - Vaultwarden:
              href: https://vaultwarden.krugten.org
              description: Password Manager
              icon: vaultwarden.png
          - Pi-hole:
              href: https://pihole.krugten.org
              description: Ad Blocker
              icon: pi-hole.png
          - Mealie:
              href: https://mealie.krugten.org
              description: Recipe Manager
              icon: mealie.png
    '';
    path = "/var/lib/homepage/services.yaml";
  };

  sops.templates."homepage-bookmarks" = {
    content = ''
      - Developer:
          - GitHub:
              href: https://github.com
              icon: github.png
    '';
    path = "/var/lib/homepage/bookmarks.yaml";
  };

  sops.templates."homepage-widgets" = {
    content = ''
      - resources:
          cpu: true
          memory: true
          disk: /
      - datetime:
          text_size: xl
          format:
            dateStyle: long
            timeStyle: short
    '';
    path = "/var/lib/homepage/widgets.yaml";
  };

  services.k3s.manifests.homepage = {
    enable = true;
    content = [
      {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "homepage";
          namespace = "homepage";
        };
        spec = {
          replicas = 1;
          strategy.type = "Recreate";
          selector.matchLabels.app = "homepage";
          template = {
            metadata.labels.app = "homepage";
            spec = {
              containers = [
                {
                  name = "homepage";
                  image = "ghcr.io/gethomepage/homepage:1.10.1";
                  ports = [{containerPort = 3000;}];
                  env = [
                    {
                      name = "HOMEPAGE_ALLOWED_HOSTS";
                      value = "home.krugten.org";
                    }
                  ];
                  volumeMounts = [
                    {
                      name = "config";
                      mountPath = "/app/config";
                    }
                    {
                      name = "secrets";
                      mountPath = "/run/secrets/rendered";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  hostPath.path = "/var/lib/homepage";
                }
                {
                  name = "secrets";
                  hostPath.path = "/run/secrets/rendered";
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
          name = "homepage";
          namespace = "homepage";
        };
        spec = {
          selector.app = "homepage";
          ports = [
            {
              port = 3000;
              targetPort = 3000;
            }
          ];
        };
      }
      {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "homepage";
          namespace = "homepage";
          annotations = {
            "kubernetes.io/ingress.class" = "nginx";
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true";
          };
        };
        spec = {
          ingressClassName = "nginx";
          tls = [
            {
              hosts = ["home.krugten.org"];
              secretName = "homepage-tls";
            }
          ];
          rules = [
            {
              host = "home.krugten.org";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "homepage";
                    port.number = 3000;
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
