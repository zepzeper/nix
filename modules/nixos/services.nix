{ config, lib, pkgs, ... }:

{
  # ===== SYSTEM SERVICES =====
  # SSH daemon
  services.openssh.enable = true;

  # Network services
  services.resolved.enable = true;

  # Hardware services
  services.udisks2.enable = true;
  services.upower.enable = true;

  services.dbus.enable = true;

  # Audio system (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  # Printing (if needed)
  # services.printing.enable = true;

  # Bluetooth (if needed)
  # hardware.bluetooth.enable = true;
  # services.blueman.enable = true;
}
