{
  config,
  lib,
  pkgs,
  ...
}: let
  # Script to disable all RGB lighting devices on boot
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

    for i in $(seq 0 $(($NUM_DEVICES - 1))); do
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color 000000
    done
  '';
in {
  # Hardware support
  hardware.i2c.enable = true; # Required for RGB device communication
  # Common kernel modules
  boot.kernelModules = ["i2c-dev"]; # Required for RGB control
  # ===== RGB LIGHTING CONTROL =====
  services.hardware.openrgb.enable = true;
  services.udev.packages = [pkgs.openrgb];

  # System service to disable RGB on boot
  systemd.services.no-rgb = {
    description = "Disable all RGB devices on boot";
    serviceConfig = {
      ExecStart = "${no-rgb}/bin/no-rgb";
      Type = "oneshot";
    };
    wantedBy = ["multi-user.target"];
  };

  # Add the script to system packages for manual use
  environment.systemPackages = [no-rgb];
}
