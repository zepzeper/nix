{
  # Machines update themselves from this repository: they pull the flake from
  # GitHub on a schedule, build it, and switch. Push to main and every machine
  # with this on follows within a day - no need to reach each laptop.
  #
  # On for employee laptops. Off (forced) for servers, which only change when
  # an admin deploys to them.
  #
  # Inputs are pinned by flake.lock, so "an update" means whatever the lock
  # says: security fixes reach machines when the lock is bumped and pushed.
  #
  # This trusts whatever lands on the branch, so protect it: require pull
  # requests or signed commits on main before employee laptops track it.
  flake.modules.nixos.services-auto-update =
    {
      config,
      lib,
      inputs,
      hostConfig,
      ...
    }:
    let
      cfg = config.zep.autoUpdate;
    in
    {
      key = "zep#services-auto-update";
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
              Reboot when an update needs it (new kernel, initrd), inside
              03:00-05:00. Wrong for someone's laptop, so the laptop profile
              forces it off.
            '';
          };
        };
      };

      config = lib.mkIf cfg.enable {
        # Without a committed flake.lock every machine would resolve all inputs
        # to their newest commit on every run - untested, and different per
        # machine. Refuse to build rather than let that happen.
        assertions = [
          {
            assertion = builtins.pathExists "${inputs.self}/flake.lock";
            message = "zep.autoUpdate needs a committed flake.lock: run `nix flake lock` and commit it.";
          }
        ];

        system.autoUpgrade = {
          enable = true;
          # The host's name in this flake, not networking.hostName, which a
          # host may change.
          flake = "${cfg.options.flake}#${hostConfig.name}";
          # Flakes pin everything; there are no channels to update.
          upgrade = false;
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
