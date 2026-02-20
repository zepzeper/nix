{...}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/home-assistant 0755 root root -"
  ];

  system.activationScripts.home-assistant-config = {
    deps = [];
    text = ''
          mkdir -p /var/lib/home-assistant

          cat > /var/lib/home-assistant/configuration.yaml << EOF
      # Loads default set of integrations. Do not remove.
      default_config:

      http:
        use_x_forwarded_for: true
        trusted_proxies:
          - 10.0.0.0/8

      frontend:
        themes: !include_dir_merge_named themes

      automation: !include automations.yaml
      script: !include scripts.yaml
      scene: !include scenes.yaml
      EOF

          touch /var/lib/home-assistant/automations.yaml
          touch /var/lib/home-assistant/scripts.yaml
          touch /var/lib/home-assistant/scenes.yaml
          mkdir -p /var/lib/home-assistant/themes
    '';
  };

  services.k3s.manifests.home-assistant = {
    enable = true;
    content = [
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "home-assistant";
      }
      {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "home-assistant-pv";
          namespace = "home-assistant";
        };
        spec = {
          capacity.storage = "5Gi";
          accessModes = ["ReadWriteOnce"];
          hostPath.path = "/var/lib/home-assistant";
        };
      }
      {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "home-assistant-pvc";
          namespace = "home-assistant";
        };
        spec = {
          accessModes = ["ReadWriteOnce"];
          resources.requests.storage = "5Gi";
        };
      }
      {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "home-assistant";
          namespace = "home-assistant";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "home-assistant";
          template = {
            metadata.labels.app = "home-assistant";
            spec = {
              containers = [
                {
                  name = "home-assistant";
                  image = "ghcr.io/home-assistant/home-assistant:stable";
                  ports = [{containerPort = 8123;}];
                  volumeMounts = [
                    {
                      name = "config";
                      mountPath = "/config";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  hostPath.path = "/var/lib/home-assistant";
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
          name = "home-assistant";
          namespace = "home-assistant";
        };
        spec = {
          selector.app = "home-assistant";
          ports = [
            {
              port = 8123;
              targetPort = 8123;
            }
          ];
        };
      }
      {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "home-assistant";
          namespace = "home-assistant";
          annotations = {
            "kubernetes.io/ingress.class" = "nginx";
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
          };
        };
        spec = {
          tls = [
            {
              hosts = ["homeassistant.krugten.org"];
              secretName = "home-assistant-tls";
            }
          ];
          rules = [
            {
              host = "homeassistant.krugten.org";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "home-assistant";
                    port.number = 8123;
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
