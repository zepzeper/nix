# Desktop features - all desktop environment features
# Import selectively based on your needs
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./dm # Display manager and window compositor
    ./audio # Sound and audio
    ./peripherals # Bluetooth and input devices
    ./networking # Desktop networking
    ./graphics
  ];
}
