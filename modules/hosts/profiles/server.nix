{ config, ... }:
{
  # A headless machine: nobody logs in at a desk, admins reach it over SSH.
  # Updates itself and may reboot inside the 03:00-05:00 window.
  flake.modules.nixos.profiles-server =
    { lib, ... }:
    {
      imports = [ config.flake.modules.nixos.profiles-base ];

      zep = {
        networking.options.mode = lib.mkDefault "networkd";

        autoUpdate = {
          enable = lib.mkDefault true;
          options.allowReboot = lib.mkDefault true;
        };
      };

      # Nothing on a server needs these.
      documentation.enable = lib.mkDefault false;
      services.pipewire.enable = lib.mkForce false;
      hardware.bluetooth.enable = lib.mkForce false;
    };
}
