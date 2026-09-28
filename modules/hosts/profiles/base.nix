{ config, lib, ... }:
let
  # Every block in the repository: all of flake.modules.nixos except the
  # profiles, the hosts, and the people (users/<name>, which a host imports).
  # A new block is picked up by being written; there is no list to remember
  # to update.
  blocks = lib.attrValues (
    lib.filterAttrs (
      name: _:
      !(lib.hasPrefix "profiles-" name || lib.hasPrefix "hosts/" name || lib.hasPrefix "users/" name)
    ) config.flake.modules.nixos
  );

  # Same for Home Manager blocks (flake.modules.homeManager.<name>): each is
  # given to every Home Manager user and, like a NixOS block, does nothing
  # until switched on.
  # A person's own settings (flake.modules.homeManager."users/<name>") are
  # not blocks: a host imports them for that user only.
  homeBlocks = lib.attrValues (
    lib.filterAttrs (name: _: !(lib.hasPrefix "users/" name)) (config.flake.modules.homeManager or { })
  );
in
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
      key = "zep#profiles-base";
      imports = blocks;

      # Mandatory on every machine.
      zep = {
        nix.enable = lib.mkForce true;
        users.enable = lib.mkForce true;
        ssh.enable = lib.mkForce true;
        hardening.enable = lib.mkForce true;

        # On by default; a host may switch these off (e.g. an ARM server
        # that keeps its SD image's partitions instead of disko).
        locale.enable = lib.mkDefault true;
        boot.enable = lib.mkDefault true;
        disk.enable = lib.mkDefault true;
        hardware.enable = lib.mkDefault true;
        networking.enable = lib.mkDefault true;
        zsh.enable = lib.mkDefault true;
        tmux.enable = lib.mkDefault true;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        # A file Home Manager wants to manage that already exists is moved
        # aside instead of failing the whole activation.
        backupFileExtension = "hm-backup";
        sharedModules = homeBlocks;
      };
    };
}
