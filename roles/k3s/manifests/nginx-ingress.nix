{pkgs, ...}: {
  system.activationScripts.k3s-manifests = {
    deps = [];
    text = let
      nginxIngress = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml";
        hash = "sha256-zabkdCoA1pt913v+X1n2MB69TEb/ajMEGgomN+P7q2A=";
      };
    in ''
      mkdir -p /var/lib/rancher/k3s/server/manifests
      cp ${nginxIngress} /var/lib/rancher/k3s/server/manifests/nginx-ingress.yaml
    '';
  };
}
