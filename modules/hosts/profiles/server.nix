{ config, ... }:
let
  # Captured here: inside the module below, `config` is the NixOS one.
  inherit (config.flake.modules.nixos) profiles-base;
in
{
  # A headless machine: nobody logs in at a desk, admins reach it over SSH.
  # Shell only, stable channel, and no automatic updates: a server changes
  # when an admin deploys to it, never on its own:
  #
  #   nixos-rebuild switch --flake .#<name> --target-host <name> --ask-sudo-password
  #
  # That push needs admins to be trusted Nix users here (zep.nix.trustAdmins).
  # The disk is not encrypted: nobody is there to type a passphrase at boot.
  flake.modules.nixos.profiles-server =
    {
      config,
      lib,
      hostConfig,
      ...
    }:
    {
      key = "zep#profiles-server";
      imports = [ profiles-base ];

      assertions = [
        {
          assertion = hostConfig.channel == "stable";
          message = "${hostConfig.name}: servers run the stable channel. Remove zep.hosts.${hostConfig.name}.channel = \"unstable\".";
        }
        {
          assertion = !config.zep.disk.options.encrypt;
          message = "${hostConfig.name}: an encrypted server waits for a passphrase at every boot, with nobody there to type it. Set up remote unlock (boot.initrd.network.ssh) before turning this on.";
        }
      ];

      zep = {
        networking.options.mode = lib.mkDefault "networkd";
        desktop.enable = lib.mkForce false;
        autoUpdate.enable = lib.mkForce false;
        nix.options.trustAdmins = lib.mkDefault true;
        hardware.options.firmwareUpdates = lib.mkDefault false;
      };

      # Nothing on a server needs these.
      documentation.enable = lib.mkDefault false;
      services.pipewire.enable = lib.mkForce false;
      hardware.bluetooth.enable = lib.mkForce false;
    };
}
