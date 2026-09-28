{ config, ... }:
{
  # A machine a person sits at: your desktop, and (through profiles-laptop)
  # every employee laptop. It has a desktop; which one is up to the laptop
  # profile or the host (zep.desktop.options.environment).
  #
  # Its disk is encrypted, forced: a stolen or discarded machine must not be
  # a data breach. A recovery key is enrolled at install, for when the
  # passphrase is forgotten - store it in the password manager. (Servers are
  # the opposite: unencrypted, so they come back after a reboot without
  # someone at the keyboard.)
  flake.modules.nixos.profiles-workstation =
    { lib, ... }:
    {
      key = "zep#profiles-workstation";
      imports = [ config.flake.modules.nixos.profiles-base ];

      zep = {
        networking.options.mode = lib.mkDefault "networkmanager";
        desktop.enable = lib.mkDefault true;
        # Drivers; the host names its GPU (zep.graphics.options.gpu).
        graphics.enable = lib.mkDefault true;

        disk.options = {
          encrypt = lib.mkForce true;
          recoveryKey = lib.mkDefault true;
        };
      };
    };
}
