{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  cfg = config;
in {
  options = {
    workstation = lib.mkEnableOption "Workstation role";
  };

  config = lib.mkIf cfg.workstation {
    users.users.${username}.extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "video"
      "audio"
    ];
    environment.systemPackages = with pkgs; [
      lm_sensors
      pciutils
      usbutils
      networkmanagerapplet
    ];
    services.fwupd.enable = true;
    services.printing.enable = lib.mkDefault true;
    services.avahi = {
      enable = lib.mkDefault true;
      nssmdns4 = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };
    nix.settings.experimental-features = ["nix-command" "flakes"];
  };
}
