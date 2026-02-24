{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config;
in {
  options = {
    server = lib.mkEnableOption "Server role";
  };

  config = lib.mkIf cfg.server {
    environment.systemPackages = with pkgs; [
      btop
      iotop
      tcpdump
      ethtool
      fzf
      jq
    ];

    services.openssh = {
      settings = {
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        ChallengeResponseAuthentication = false;
      };
    };

    networking.firewall = {
      enable = lib.mkDefault true;
      allowPing = true;
    };

    services.pipewire.enable = lib.mkForce false;
    hardware.bluetooth.enable = lib.mkForce false;
    system.autoUpgrade.enable = lib.mkDefault false;
  };
}
