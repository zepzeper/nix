{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    podman
    podman-compose  # Docker Compose alternative
    buildah         # Container image builder (optional)
    skopeo          # Container image operations (optional)
  ];

  # Enable container support
  virtualisation.podman = {
    enable = true;
    # Docker compatibility layer
    dockerCompat = true;
    # Default container registry
    defaultNetwork.settings.dns_enabled = true;
  };
}
