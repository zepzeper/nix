# Desktop networking configuration
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.features;
in {
  # TODO: Add extra conditionals
  options.features = {
    networking = lib.mkEnableOption "Networking";
  };

  config = lib.mkIf cfg.networking {
    # Firewall configuration
    networking.firewall = {
      enable = lib.mkDefault true;

      # Desktop-specific ports
      allowedTCPPorts = lib.mkDefault [
        8080 # Development servers
      ];

      # mDNS for local network discovery
      allowedUDPPorts = lib.mkDefault [
        5353 # mDNS
      ];
    };

    # NetworkManager configuration
    networking.networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };
}
