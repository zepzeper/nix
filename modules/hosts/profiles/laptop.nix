{ config, ... }:
{
  # An employee laptop. A workstation, plus what a machine that leaves the
  # office needs:
  #
  # - Plasma by default, the easiest switch from Windows; a laptop can set
  #   zep.desktop.options.environment = "gnome" instead;
  # - the disk is encrypted, forced: a lost laptop must not be a data breach;
  # - it updates itself from this repository, so you never have to reach it;
  #   it never reboots on its own, the person decides when;
  # - it runs the stable channel, never unstable: someone else depends on it.
  flake.modules.nixos.profiles-laptop =
    { lib, hostConfig, ... }:
    {
      imports = [ config.flake.modules.nixos.profiles-workstation ];

      assertions = [
        {
          assertion = hostConfig.channel == "stable";
          message = "${hostConfig.name}: employee laptops run the stable channel. Remove zep.hosts.${hostConfig.name}.channel = \"unstable\".";
        }
      ];

      zep = {
        desktop.options.environment = lib.mkDefault "plasma";

        disk.options.encrypt = lib.mkForce true;

        autoUpdate = {
          enable = lib.mkDefault true;
          options.allowReboot = lib.mkForce false;
        };
      };

      services.power-profiles-daemon.enable = lib.mkDefault true;
    };
}
