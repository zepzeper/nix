# Desktop networking configuration
{
  config,
  pkgs,
  lib,
  ...
}: {
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
}
