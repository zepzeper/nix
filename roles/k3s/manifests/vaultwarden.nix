{...}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/vaultwarden 0755 root root -"
  ];

  services.k3s.manifests.vaultwarden = {
    enable = true;
    content = [
      {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "vaultwarden";
          namespace = "vaultwarden";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "vaultwarden";
          template = {
            metadata.labels.app = "vaultwarden";
            spec = {
              containers = [
                {
                  name = "vaultwarden";
                  image = "vaultwarden/server:1.35.3";
                  ports = [{containerPort = 80;}];
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  hostPath.path = "/var/lib/vaultwarden";
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
          name = "vaultwarden";
          namespace = "vaultwarden";
        };
        spec = {
          selector.app = "vaultwarden";
          ports = [
            {
              port = 80;
              targetPort = 80;
            }
          ];
        };
      }
      {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "vaultwarden";
          namespace = "vaultwarden";
          annotations = {
            "kubernetes.io/ingress.class" = "nginx";
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
          };
        };
        spec = {
          tls = [
            {
              hosts = ["vaultwarden.krugten.org"];
              secretName = "vaultwarden-tls";
            }
          ];
          rules = [
            {
              host = "vaultwarden.krugten.org";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "vaultwarden";
                    port.number = 80;
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
