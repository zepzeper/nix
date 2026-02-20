{
  config,
  pkgs,
  ...
}: {
  system.activationScripts.k3s-cert-manager = {
    deps = ["k3s-manifests"];
    text = let
      certManager = pkgs.fetchurl {
        url = "https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml";
        hash = "sha256-/Kr1EAKlaln2W2TKLaAhqTpRczwhqOhHjnJjwA7/fNA=";
      };
    in ''
      mkdir -p /var/lib/rancher/k3s/server/manifests
      cp ${certManager} /var/lib/rancher/k3s/server/manifests/cert-manager.yaml
    '';
  };

  systemd.services.k3s-cloudflare-secret = {
    description = "Create Cloudflare API token secret in Kubernetes";
    after = ["k3s.service" "sops-nix.service"];
    wants = ["k3s.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "KUBECONFIG=/etc/rancher/k3s/k3s.yaml";
    };
    script = ''
      until ${pkgs.kubectl}/bin/kubectl get nodes; do sleep 2; done

      ${pkgs.kubectl}/bin/kubectl create namespace cert-manager --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -
      ${pkgs.kubectl}/bin/kubectl create namespace home-assistant --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -

      for namespace in cert-manager home-assistant; do
        ${pkgs.kubectl}/bin/kubectl create secret generic cloudflare-api-token \
          --from-file=api-token=${config.sops.secrets."cloudflare-api-token".path} \
          --namespace $namespace \
          --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -
      done
    '';
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
