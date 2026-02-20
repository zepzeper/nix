{pkgs, ...}: {
  services.k3s.manifests.nginx-ingress = {
    enable = true;
    source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml";
      hash = "sha256-zabkdCoA1pt913v+X1n2MB69TEb/ajMEGgomN+P7q2A=";
    };
  };
}
