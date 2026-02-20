{
  config,
  pkgs,
  ...
}: {
  services.k3s.manifests.cert-manager = {
    enable = true;
    source = pkgs.fetchurl {
      url = "https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml";
      hash = "sha256-/Kr1EAKlaln2W2TKLaAhqTpRczwhqOhHjnJjwA7/fNA=";
    };
  };

  sops.templates.cloudflare-secret-cert-manager = {
    content = builtins.toJSON {
      apiVersion = "v1";
      kind = "Secret";
      metadata = {
        name = "cloudflare-api-token";
        namespace = "cert-manager";
      };
      stringData."api-token" = config.sops.placeholder.cloudflare-api-token;
    };
    path = "/var/lib/rancher/k3s/server/manifests/cloudflare-secret-cert-manager.json";
  };

  sops.templates.cloudflare-secret-home-assistant = {
    content = builtins.toJSON {
      apiVersion = "v1";
      kind = "Secret";
      metadata = {
        name = "cloudflare-api-token";
        namespace = "home-assistant";
      };
      stringData."api-token" = config.sops.placeholder.cloudflare-api-token;
    };
    path = "/var/lib/rancher/k3s/server/manifests/cloudflare-secret-home-assistant.json";
  };

  sops.templates.cloudflare-secret-pihole = {
    content = builtins.toJSON {
      apiVersion = "v1";
      kind = "Secret";
      metadata = {
        name = "cloudflare-api-token";
        namespace = "pihole";
      };
      stringData."api-token" = config.sops.placeholder.cloudflare-api-token;
    };
    path = "/var/lib/rancher/k3s/server/manifests/cloudflare-secret-pihole.json";
  };

  sops.templates.cloudflare-secret-tuliprox = {
    content = builtins.toJSON {
      apiVersion = "v1";
      kind = "Secret";
      metadata = {
        name = "cloudflare-api-token";
        namespace = "tuliprox";
      };
      stringData."api-token" = config.sops.placeholder.cloudflare-api-token;
    };
    path = "/var/lib/rancher/k3s/server/manifests/cloudflare-secret-tuliprox.json";
  };

  services.k3s.manifests.namespaces = {
    enable = true;
    content = [
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "cert-manager";
      }
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "home-assistant";
      }
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "vaultwarden";
      }
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "pihole";
      }
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "tuliprox";
      }
    ];
  };

  services.k3s.manifests.cluster-issuer = {
    enable = true;
    content = [
      {
        apiVersion = "cert-manager.io/v1";
        kind = "ClusterIssuer";
        metadata.name = "letsencrypt-prod";
        spec.acme = {
          email = "wouterschiedam98@gmail.com";
          server = "https://acme-v02.api.letsencrypt.org/directory";
          privateKeySecretRef.name = "letsencrypt-prod";
          solvers = [
            {
              dns01.cloudflare.apiTokenSecretRef = {
                name = "cloudflare-api-token";
                key = "api-token";
              };
            }
          ];
        };
      }
    ];
  };
}
