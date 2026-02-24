{...}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/pihole/etc 0755 root root -"
    "d /var/lib/pihole/dnsmasq 0755 root root -"
  ];

  services.k3s.manifests.pihole = {
    enable = true;
    content = [
      {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "pihole";
          namespace = "pihole";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "pihole";
          template = {
            metadata.labels.app = "pihole";
            spec = {
              hostNetwork = true;
              dnsPolicy = "ClusterFirstWithHostNet";
              containers = [
                {
                  name = "pihole";
                  image = "pihole/pihole:2025.11.1";
                  env = [
                    {
                      name = "TZ";
                      value = "Europe/Amsterdam";
                    }
                    {
                      name = "FTLCONF_webserver_port";
                      value = "8080";
                    }
                    {
                      name = "FTLCONF_webserver_api_password";
                      value = "changeme";
                    }
                  ];
                  ports = [
                    {
                      containerPort = 53;
                      protocol = "TCP";
                    }
                    {
                      containerPort = 53;
                      protocol = "UDP";
                    }
                    {
                      containerPort = 8080;
                      protocol = "TCP";
                    }
                  ];
                  volumeMounts = [
                    {
                      name = "etc";
                      mountPath = "/etc/pihole";
                    }
                    {
                      name = "dnsmasq";
                      mountPath = "/etc/dnsmasq.d";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "etc";
                  hostPath.path = "/var/lib/pihole/etc";
                }
                {
                  name = "dnsmasq";
                  hostPath.path = "/var/lib/pihole/dnsmasq";
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
          name = "pihole";
          namespace = "pihole";
        };
        spec = {
          selector.app = "pihole";
          ports = [
            {
              name = "dns-tcp";
              port = 53;
              targetPort = 53;
              protocol = "TCP";
            }
            {
              name = "dns-udp";
              port = 53;
              targetPort = 53;
              protocol = "UDP";
            }
            {
              name = "web";
              port = 80;
              targetPort = 8080;
            }
          ];
        };
      }
      {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "pihole";
          namespace = "pihole";
          annotations = {
            "kubernetes.io/ingress.class" = "nginx";
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
          };
        };
        spec = {
          tls = [
            {
              hosts = ["pihole.krugten.org"];
              secretName = "pihole-tls";
            }
          ];
          rules = [
            {
              host = "pihole.krugten.org";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "pihole";
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
