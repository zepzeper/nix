{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  # K3s agent (worker)
  # services.k3s = {
  #   enable = true;
  #   role = "agent";
  #   tokenFile = config.sops.secrets."k3s-token".path;
  # };

  # Firewall ports for k3s agent
  networking.firewall = {
    allowedTCPPorts = [
      10250 # Kubelet
    ];
    allowedUDPPorts = [
      8472 # VXLAN/Flannel
    ];
  };

  environment.systemPackages = with pkgs; [
    k3s
  ];
}
