# Template: a server. Copy to modules/hosts/servers/<name>.nix and replace
# "server" with the machine's name.
#
# The server profile uses systemd-networkd (DHCP on wired ports), updates
# itself and may reboot between 03:00 and 05:00.
{ config, ... }:
{
  flake.modules.nixos."hosts/server" = {
    imports = [
      config.flake.modules.nixos.profiles-server
      # ./_server-hardware.nix
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05"; # the release it was installed with; never change

    zep = {
      disk.options.device = "/dev/disk/by-id/CHANGE-ME";

      users.options.admins.zepzeper.sshKeys = [ "ssh-ed25519 AAAA... CHANGE-ME" ];
    };

    # A Raspberry Pi instead: aarch64, U-Boot, and the SD image's own
    # filesystem rather than disko.
    #   nixpkgs.hostPlatform = "aarch64-linux";
    #   zep.boot.options.loader = "extlinux";
    #   zep.disk.enable = false;
    #   fileSystems."/" = { device = "/dev/disk/by-label/NIXOS_SD"; fsType = "ext4"; };
  };
}
