{
  # Machines update themselves from this repository: they pull the flake from
  # GitHub on a schedule, build it, and switch. Push to main and every machine
  # with this on follows within a day - no need to reach each laptop.
  #
  # This trusts whatever lands on the branch, so protect it: require pull
  # requests or signed commits on main before employee laptops track it.
  flake.modules.nixos.services-auto-update =
    { config, lib, ... }:
    let
      cfg = config.zep.autoUpdate;
    in
    {
      options.zep.autoUpdate = {
        enable = lib.mkEnableOption "automatic updates from this flake";

        options = {
          flake = lib.mkOption {
            type = lib.types.str;
            default = "github:zepzeper/nix";
            description = "Flake to update from; the host's own configuration is picked by hostname.";
          };
          dates = lib.mkOption {
            type = lib.types.str;
            default = "daily";
            description = "When to check, as a systemd calendar expression.";
          };
          allowReboot = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Reboot when an update needs it (new kernel, initrd). Fine for
              servers inside rebootWindow; wrong for someone's laptop.
            '';
          };
        };
      };

      config = lib.mkIf cfg.enable {
        system.autoUpgrade = {
          enable = true;
          flake = "${cfg.options.flake}#${config.networking.hostName}";
          inherit (cfg.options) dates allowReboot;
          randomizedDelaySec = "45min";
          persistent = true;
          rebootWindow = lib.mkIf cfg.options.allowReboot {
            lower = "03:00";
            upper = "05:00";
          };
        };
      };
    };
}
