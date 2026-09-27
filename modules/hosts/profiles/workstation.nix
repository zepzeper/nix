{ config, ... }:
{
  # A machine a person sits at: your desktop, and (through profiles-laptop)
  # every employee laptop. It has a desktop; which one is up to the laptop
  # profile or the host (zep.desktop.options.environment).
  flake.modules.nixos.profiles-workstation =
    { lib, ... }:
    {
      imports = [ config.flake.modules.nixos.profiles-base ];

      zep = {
        networking.options.mode = lib.mkDefault "networkmanager";
        desktop.enable = lib.mkDefault true;
      };
    };
}
