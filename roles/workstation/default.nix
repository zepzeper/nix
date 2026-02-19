# Workstation role - full desktop environment
# Builds on minimal role and adds GUI, multimedia, and desktop applications
{
  config,
  pkgs,
  lib,
  username,
  inputs,
  ...
}: {
  imports = [
    ../../roles/minimal
    ../../modules/nixos/features/desktop
    ../../modules/nixos/desktop/apps
    ../../modules/nixos/desktop/services
  ];

  # Workstation users need more privileges
  users.users.${username}.extraGroups = [
    "wheel"
    "networkmanager"
    "docker"
    "video"
    "audio"
  ];

  # Additional workstation packages
  environment.systemPackages = with pkgs; [
    # System utilities
    lm_sensors
    pciutils
    usbutils

    # Network tools
    networkmanagerapplet
  ];

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Enable fwupd for firmware updates
  services.fwupd.enable = true;

  # Printing support
  services.printing.enable = lib.mkDefault true;
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
  };

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
