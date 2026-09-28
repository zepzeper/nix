{
  # Boot loader. systemd-boot for UEFI machines (desktop, laptops, most
  # servers); extlinux for boards like the Raspberry Pi that boot through
  # U-Boot.
  flake.modules.nixos.boot-loader =
    { config, lib, ... }:
    let
      cfg = config.zep.boot;
    in
    {
      key = "zep#boot-loader";
      options.zep.boot = {
        enable = lib.mkEnableOption "boot loader";

        options = {
          loader = lib.mkOption {
            type = lib.types.enum [
              "systemd-boot"
              "extlinux"
            ];
            default = "systemd-boot";
          };
          generations = lib.mkOption {
            type = lib.types.ints.positive;
            default = 10;
            description = "Generations listed in the boot menu (keeps /boot from filling up).";
          };
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.mkIf (cfg.options.loader == "systemd-boot") {
            boot.loader = {
              systemd-boot = {
                enable = true;
                configurationLimit = cfg.options.generations;
                editor = false;
              };
              efi.canTouchEfiVariables = lib.mkDefault true;
            };
          })
          (lib.mkIf (cfg.options.loader == "extlinux") {
            boot.loader = {
              grub.enable = false;
              generic-extlinux-compatible = {
                enable = true;
                configurationLimit = cfg.options.generations;
              };
            };
          })
          {
            # systemd in the initrd, for every loader: the scripted initrd is
            # deprecated (removed in 26.11), and TPM2/FIDO2 unlock need this.
            boot.initrd.systemd.enable = lib.mkDefault true;
          }
        ]
      );
    };
}
