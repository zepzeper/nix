# Graphics/GPU configuration
# Select GPU type per-host
{
  config,
  pkgs,
  lib,
  ...
}: let 
  cfg = config.features;
in{
  options.features = {
    gpu = lib.mkOption {
      type = lib.types.enum ["none" "nvidia" "amd" "intel"];
      default = "none";
      description = "GPU type to configure";
    };
  };

  config = lib.mkMerge [
    # NVIDIA configuration
    (lib.mkIf (config.features.gpu == "nvidia") {
      services.xserver.videoDrivers = ["nvidia"];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    })

    # AMD configuration
    (lib.mkIf (config.features.gpu == "amd") {
      services.xserver.videoDrivers = ["amdgpu"];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          mesa
          libva
          libvdpau-va-gl
        ];
      };

      hardware.amdgpu.initrd.enable = true;

      environment.systemPackages = with pkgs; [
        lact # AMD GPU control
      ];
    })

    # Intel configuration
    (lib.mkIf (config.features.gpu == "intel") {
      services.xserver.videoDrivers = ["modesetting"];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          mesa
          libva
          intel-media-driver
          intel-vaapi-driver
        ];
      };

      environment.systemPackages = with pkgs; [
        intel-gpu-tools
      ];
    })
  ];
}
