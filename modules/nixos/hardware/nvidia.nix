{ config, lib, pkgs, ... }:

{
  # ===== GRAPHICS =====
  hardware.graphics.enable = true;
  # ===== NVIDIA CONFIGURATION =====
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;  # Use proprietary drivers
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Network tuning for better performance
  boot.kernel.sysctl = {
    # Disable IPv6 completely
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
    "net.ipv6.conf.lo.disable_ipv6" = 1;
    # Increase network buffer sizes for better performance
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
  };
}
