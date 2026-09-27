{ config, ... }:
{
  # An employee laptop. A workstation, plus what a machine that leaves the
  # office needs:
  #
  # - the disk is encrypted, forced: a lost laptop must not be a data breach;
  # - it updates itself from this repository, so you never have to reach it;
  #   it never reboots on its own, the person decides when.
  flake.modules.nixos.profiles-laptop =
    { lib, ... }:
    {
      imports = [ config.flake.modules.nixos.profiles-workstation ];

      zep = {
        disk.options.encrypt = lib.mkForce true;

        autoUpdate = {
          enable = lib.mkDefault true;
          options.allowReboot = lib.mkForce false;
        };
      };

      services.power-profiles-daemon.enable = lib.mkDefault true;
    };
}
