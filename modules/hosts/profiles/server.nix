{ config, ... }:
{
  # A headless machine: nobody logs in at a desk, admins reach it over SSH.
  # Shell only, stable channel, and no automatic updates: a server changes
  # when an admin deploys to it, never on its own.
  #
  #   nixos-rebuild switch --flake .#<name> --target-host <name> --sudo
  flake.modules.nixos.profiles-server =
    { lib, hostConfig, ... }:
    {
      imports = [ config.flake.modules.nixos.profiles-base ];

      assertions = [
        {
          assertion = hostConfig.channel == "stable";
          message = "${hostConfig.name}: servers run the stable channel. Remove zep.hosts.${hostConfig.name}.channel = \"unstable\".";
        }
      ];

      zep = {
        networking.options.mode = lib.mkDefault "networkd";
        desktop.enable = lib.mkForce false;
        autoUpdate.enable = lib.mkForce false;
      };

      # Nothing on a server needs these.
      documentation.enable = lib.mkDefault false;
      services.pipewire.enable = lib.mkForce false;
      hardware.bluetooth.enable = lib.mkForce false;
    };
}
