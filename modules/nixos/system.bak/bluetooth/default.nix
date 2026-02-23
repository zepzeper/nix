{
  config,
  pkgs,
  ...
}: {
  # Enable Bluetooth hardware support
  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    bluetui
    bluez
  ];
}
