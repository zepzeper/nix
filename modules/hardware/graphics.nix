{
  # Graphics drivers. On for workstations and laptops (the workstation
  # profile); a host names its GPU:
  #
  #   zep.graphics.options.gpu = "nvidia";   # or "intel", "amd"
  #
  # Intel and AMD run on Mesa and need little; the block adds their video
  # decoding. NVIDIA runs on NVIDIA's own driver, and the card's generation
  # decides which driver and which kernel module:
  #
  #   turing-or-newer    RTX 20/30/40/50, GTX 16xx: the current driver with
  #                      NVIDIA's open kernel module (their recommendation)
  #   pascal-or-maxwell  GTX 9xx/10xx: the 580 legacy branch (supported to
  #                      2028) with the closed module - the current driver
  #                      and the open module no longer support these cards
  #
  # Check the card with `lspci | grep -i vga` (or the old machine's settings).
  flake.modules.nixos.hardware-graphics =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zep.graphics;
      nvidia = cfg.options.gpu == "nvidia";
      modern = cfg.options.nvidiaGeneration == "turing-or-newer";
      nvidiaPackages = config.boot.kernelPackages.nvidiaPackages;

      # niri's recommended fix for NVIDIA not returning freed video memory
      # to the pool: without it niri can grow towards 1 GiB of VRAM instead
      # of ~100 MiB. https://niri-wm.github.io/niri/Nvidia.html
      niriVramProfile = {
        rules = [
          {
            pattern = {
              feature = "procname";
              matches = "niri";
            };
            profile = "Limit Free Buffer Pool On Wayland Compositors";
          }
        ];
        profiles = [
          {
            name = "Limit Free Buffer Pool On Wayland Compositors";
            settings = [
              {
                key = "GLVidHeapReuseRatio";
                value = 0;
              }
            ];
          }
        ];
      };
    in
    {
      key = "zep#hardware-graphics";

      options.zep.graphics = {
        enable = lib.mkEnableOption "graphics drivers";

        options = {
          gpu = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.enum [
                "intel"
                "amd"
                "nvidia"
              ]
            );
            default = null;
            description = ''
              The GPU that drives the screens. null: plain Mesa, which works
              for Intel and AMD without video-decoding extras.
            '';
          };

          nvidiaGeneration = lib.mkOption {
            type = lib.types.enum [
              "turing-or-newer"
              "pascal-or-maxwell"
            ];
            default = "turing-or-newer";
            description = "For gpu = \"nvidia\": the card's generation, which picks driver and kernel module.";
          };
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            hardware.graphics = {
              enable = true;
              # 32-bit drivers, for Steam and Wine.
              enable32Bit = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
            };
          }

          (lib.mkIf (cfg.options.gpu == "intel") {
            hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
            environment.sessionVariables.LIBVA_DRIVER_NAME = lib.mkDefault "iHD";
          })

          (lib.mkIf (cfg.options.gpu == "amd") {
            # The driver in the initrd: the right resolution from the first
            # boot screen, including the disk passphrase prompt.
            hardware.amdgpu.initrd.enable = lib.mkDefault true;
          })

          (lib.mkIf nvidia {
            # The NixOS NVIDIA module keys off this list, on Wayland too.
            services.xserver.videoDrivers = [ "nvidia" ];

            hardware.nvidia = {
              open = modern;
              package = if modern then nvidiaPackages.production else nvidiaPackages.legacy_580;
              # Kernel modesetting: required for Wayland (the default since
              # driver 535; set explicitly because niri depends on it).
              modesetting.enable = true;
              # Keep video memory across suspend, so apps and the desktop
              # come back intact after sleep.
              powerManagement.enable = lib.mkDefault true;
              nvidiaSettings = lib.mkDefault true;
            };

            # Hardware video decoding in browsers and players, through VA-API.
            hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];
            environment.sessionVariables = {
              LIBVA_DRIVER_NAME = "nvidia";
              NVD_BACKEND = "direct";
            };

            environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri-vram.json".text =
              builtins.toJSON niriVramProfile;
          })
        ]
      );
    };
}
