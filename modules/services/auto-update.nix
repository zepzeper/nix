{
  # Machines update themselves from this repository: they pull the flake from
  # GitHub on a schedule, build it, and switch. Push to main and every machine
  # with this on follows within a day - no need to reach each laptop.
  #
  # On for employee laptops. Off by default for servers, which change when an
  # admin deploys to them; a server can follow main instead (the test server:
  # every few minutes, only when main moved - options.onlyWhenChanged).
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
      pkgs,
      inputs,
      hostConfig,
      ...
    }:
    let
      cfg = config.zep.autoUpdate;
      flake = "${cfg.options.flake}#${hostConfig.name}";

      # Is there a newer commit than the one this system was built from?
      updateAvailable = pkgs.writeShellApplication {
        name = "update-available";
        runtimeInputs = [
          config.nix.package
          pkgs.jq
          pkgs.coreutils
          pkgs.findutils
        ];
        text = builtins.readFile ./scripts/update-available;
      };
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
          randomizedDelay = lib.mkOption {
            type = lib.types.str;
            default = "45min";
            description = "Random delay before each run, so machines do not all update at once.";
          };
          onlyWhenChanged = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Build only when the flake has a newer commit than the running
              system, so a frequent schedule costs a quick check, not a build.
              A commit that fails is tried again after an hour, not on every
              run; a switch to anything else (a local build) is replaced by
              the flake's commit at the next run.
            '';
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
          inherit flake;
          # Flakes pin everything; there are no channels to update.
          upgrade = false;
          inherit (cfg.options) dates allowReboot;
          randomizedDelaySec = cfg.options.randomizedDelay;
          persistent = true;
          rebootWindow = lib.mkIf cfg.options.allowReboot {
            lower = "03:00";
            upper = "05:00";
          };
        };

        # Exit status 1 skips the run without counting as a failure. The
        # commit last tried is kept in /var/lib/nixos-upgrade/tried, so a
        # commit that does not build is retried hourly, not on every run.
        systemd.services.nixos-upgrade.serviceConfig = lib.mkIf cfg.options.onlyWhenChanged {
          StateDirectory = "nixos-upgrade";
          ExecCondition = "${lib.getExe updateAvailable} ${cfg.options.flake} /var/lib/nixos-upgrade/tried";
        };
      };
    };
}
