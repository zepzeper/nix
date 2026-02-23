# Peripherals configuration
# Bluetooth and input devices
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.features;
in {
  options.features = {
    peripherals = lib.mkEnableOption "Peripherals";
  };

  config = lib.mkIf cfg.peripherals {
      # Bluetooth
      hardware.bluetooth = {
        enable = true;
      };

      # Additional peripheral packages
      environment.systemPackages = with pkgs; [
        bluez
        bluez-tools
      ];
  };
}
