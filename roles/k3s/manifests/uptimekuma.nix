{...}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/kuma 0755 root root -"
  ];

  services.k3s.manifests.kuma = {
    enable = true;
    content = [
      {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "kuma";
          namespace = "kuma";
        };
        spec = {
          replicas = 1;
          strategy.type = "Recreate";
          selector.matchLabels.app = "kuma";
          template = {
            metadata.labels.app = "kuma";
            spec = {
              containers = [
                {
                  name = "kuma";
                  image = "louislam/uptime-kuma:1.23.16";
                  ports = [{containerPort = 3001;}];
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/app/data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  hostPath.path = "/var/lib/kuma";
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
          name = "kuma";
          namespace = "kuma";
        };
        spec = {
          selector.app = "kuma";
          ports = [
            {
              port = 3001;
              targetPort = 3001;
            }
          ];
        };
      }
      {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "kuma";
          namespace = "kuma";
          annotations = {
            "kubernetes.io/ingress.class" = "nginx";
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
            "external-dns.alpha.kubernetes.io/hostname" = "kuma.krugten.org";
          };
        };
        spec = {
          tls = [
            {
              hosts = ["kuma.krugten.org"];
              secretName = "kuma-tls";
            }
          ];
          rules = [
            {
              host = "kuma.krugten.org";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "kuma";
                    port.number = 3001;
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
