# Template: a server. Copy to modules/hosts/servers/<name>.nix and replace
# "server" with the machine's name.
#
# The server profile: shell only, stable channel, systemd-networkd (DHCP on
# wired ports), unencrypted disk, and no automatic updates. Deploy changes
# from your own machine:
#   nixos-rebuild switch --flake .#server --target-host server --ask-sudo-password
# For a Raspberry Pi use templates/host-pi.nix instead.
{ config, ... }:
{
  flake.modules.nixos."hosts/server" = {
    imports = [
      config.flake.modules.nixos.profiles-server
      # ./_server-hardware.nix
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05"; # `nixos-version` at install time (first two numbers); never change

    zep = {
      disk.options.device = "/dev/disk/by-id/CHANGE-ME";

      users.options.admins.zepzeper.sshKeys = [ "ssh-ed25519 AAAA... CHANGE-ME" ];
    };
  };
}
