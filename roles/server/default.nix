# Server role - headless server configuration
# Builds on minimal role and adds server-specific settings
{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  imports = [
    ../../roles/minimal
  ];

  # Additional server packages
  environment.systemPackages = with pkgs; [
    btop
    iotop
    tcpdump
    ethtool
  ];

  # SSH configuration - key-only authentication
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;  # Key-only auth
      PubkeyAuthentication = true;
      ChallengeResponseAuthentication = false;
    };
  };

  # Firewall - servers often need explicit port management
  networking.firewall = {
    enable = lib.mkDefault true;
    allowPing = true;
  };

  # Server users - ensure wheel group
  users.users.${username}.extraGroups = lib.mkDefault [ "wheel" ];

  # Sudo configuration - requires password (set in host config via hashedPassword)
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;  # Require password for sudo
  };

  # No sound/audio needed on most servers
  hardware.pulseaudio.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;

  # No Bluetooth on servers
  hardware.bluetooth.enable = lib.mkForce false;

  # Auto-upgrade disabled by default - manage manually
  system.autoUpgrade.enable = lib.mkDefault false;
}
