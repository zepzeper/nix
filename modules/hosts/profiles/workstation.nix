{ config, ... }:
{
  # A machine a person sits at: your desktop, and (through profiles-laptop)
  # every employee laptop. Desktop environment, audio and apps are blocks
  # still to be written; they get switched on here with lib.mkDefault.
  flake.modules.nixos.profiles-workstation =
    { lib, ... }:
    {
      imports = [ config.flake.modules.nixos.profiles-base ];

      zep.networking.options.mode = lib.mkDefault "networkmanager";
    };
}
