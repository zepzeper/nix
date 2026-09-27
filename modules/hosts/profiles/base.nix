{ config, ... }:
{
  # The base every machine imports. Two jobs:
  #
  # 1. Import every block, so each `zep.<block>.enable` option exists on every
  #    host. Importing does not turn anything on: blocks are off until a
  #    profile or a host enables them.
  # 2. Force on the few blocks every machine must have, with lib.mkForce, so a
  #    host cannot drop them by accident. Everything else uses lib.mkDefault
  #    or is left to the profile or host.
  flake.modules.nixos.profiles-base =
    { lib, ... }:
    {
      imports = with config.flake.modules.nixos; [
        base-hardening
        base-locale
        base-nix
        base-ssh
        base-users
        boot-loader
        desktop
        desktops-gnome
        desktops-niri
        desktops-plasma
        disk-layout
        hardware-base
        networking
        services-auto-update
      ];

      # Mandatory on every machine.
      zep = {
        nix.enable = lib.mkForce true;
        users.enable = lib.mkForce true;
        ssh.enable = lib.mkForce true;
        hardening.enable = lib.mkForce true;

        # On by default; a host may switch these off (e.g. a Pi image
        # without disko).
        locale.enable = lib.mkDefault true;
        boot.enable = lib.mkDefault true;
        disk.enable = lib.mkDefault true;
        hardware.enable = lib.mkDefault true;
        networking.enable = lib.mkDefault true;

        # Admins on every machine. A host adds to this, never replaces it.
        # users.options.admins.zepzeper.sshKeys = [ "ssh-ed25519 AAAA..." ];
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
}
