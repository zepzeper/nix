{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  imports = [
    ./manifests/nginx-ingress.nix
    ./manifests/home-assistant.nix
    ./manifests/cert-manager.nix
  ];

  # Tailscale on master host
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale-authkey".path;
    authKeyParameters = {
      ephemeral = false;
      preauthorized = true;
    };
  };

  # K3s server (control plane)
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets."k3s-token".path;
    extraFlags = "--disable traefik";
  };

  # Kubernetes tools
  environment.systemPackages = with pkgs; [
    k3s
    kubectl
    k9s
    kubernetes-helm
  ];

  # Firewall ports for k3s
  networking.firewall = {
    allowedTCPPorts = [
      6443 # Kubernetes API server
      10250 # Kubelet metrics
      10251 # kube-scheduler
      10252 # kube-controller-manager
    ];
    allowedUDPPorts = [
      8472 # VXLAN/Flannel networking
    ];
  };
}
