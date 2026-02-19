# Peripherals configuration
# Bluetooth and input devices
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  # Additional peripheral packages
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];
}
