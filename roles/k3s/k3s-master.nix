{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  cfg = config.k3s;
in {
    imports = [
        ./manifests/cert-manager.nix
        ./manifests/home-assistant.nix
        ./manifests/homepage.nix
        ./manifests/mealie.nix
        ./manifests/nginx-ingress.nix
        ./manifests/pihole.nix
        ./manifests/tuliprox.nix
        ./manifests/vaultwarden.nix
    ];

  options.k3s = {
    master = lib.mkEnableOption "K3s master node";
  };


  config = lib.mkIf cfg.master {
# Dont restart services for downtime
      systemd.services.containerd.restartIfChanged = false;
      systemd.services.kubelet.restartIfChanged = false;

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale-authkey".path;
      authKeyParameters = {
        ephemeral = false;
        preauthorized = true;
      };
      extraUpFlags = [
        "--advertise-routes=192.168.1.0/24"
      ];
    };

    services.k3s = {
      enable = true;
      role = "server";
      tokenFile = config.sops.secrets."k3s-token".path;
      extraFlags = "--disable traefik --write-kubeconfig-mode 644";
    };

    environment.systemPackages = with pkgs; [
      k3s
      kubectl
      k9s
      kubernetes-helm
    ];

    networking.firewall = {
      allowedTCPPorts = [
        6443
        10250
        10251
        10252
        53
      ];
      allowedUDPPorts = [
        8472
        53
      ];
    };
  };
}
