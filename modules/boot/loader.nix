{ inputs, ... }:
{
  # Boot loader. systemd-boot for UEFI machines (desktop, laptops, most
  # servers); GRUB for machines that may boot either UEFI or legacy BIOS
  # (Hetzner Cloud VMs); extlinux for ARM servers that boot through U-Boot.
  #
  # options.secureBoot (on for workstations and laptops): Secure Boot with
  # the machine's own keys, through lanzaboote, which signs every boot entry
  # (systemd-boot and a signed kernel+initrd image per generation). Setting
  # it up:
  # 1. The first switch (or first boot) with it creates the keys in
  #    /var/lib/sbctl (on the encrypted disk) and puts them, signed, on the
  #    boot partition. (A machine moving from plain systemd-boot: see
  #    boot.md for its old menu entries.)
  # 2. In the firmware settings, with Secure Boot still off, clear its keys
  #    (Setup Mode). At the next boot systemd-boot enrolls the keys itself -
  #    mine plus Microsoft's, which graphics cards' firmware needs.
  # 3. Only when `sbctl status` shows them (Vendor Keys: microsoft, not
  #    builtin-PK) turn Secure Boot on. Turned on before that, the firmware
  #    refuses the boot loader: a black screen after the logo. boot.md has
  #    the steps.
  # From then on the firmware only starts boot files signed with this
  # machine's key: a tampered boot partition does not boot.
  flake.modules.nixos.boot-loader =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zep.boot;
    in
    {
      key = "zep#boot-loader";
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      options.zep.boot = {
        enable = lib.mkEnableOption "boot loader";

        options = {
          loader = lib.mkOption {
            type = lib.types.enum [
              "systemd-boot"
              "grub"
              "extlinux"
            ];
            default = "systemd-boot";
          };
          secureBoot = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Secure Boot with the machine's own keys (lanzaboote), set up by itself.";
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
          {
            assertions = [
              {
                assertion = cfg.options.secureBoot -> cfg.options.loader == "systemd-boot";
                message = "zep.boot.options.secureBoot works with the systemd-boot loader (UEFI) only.";
              }
            ];
          }
          (lib.mkIf (cfg.options.loader == "systemd-boot" && cfg.options.secureBoot) {
            # lanzaboote installs (a signed) systemd-boot itself.
            boot.loader.systemd-boot.enable = lib.mkForce false;
            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
              configurationLimit = cfg.options.generations;
              autoGenerateKeys.enable = true;
              autoEnrollKeys.enable = true;
            };
            environment.systemPackages = [ pkgs.sbctl ];
          })
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
          # GRUB for machines that may boot either way, UEFI or legacy BIOS
          # (Hetzner Cloud VMs): installed on the disk for BIOS (with the disk
          # layout's biosBoot partition) and at the ESP's fallback path for
          # UEFI, without firmware boot entries.
          (lib.mkIf (cfg.options.loader == "grub") {
            boot.loader = {
              grub = {
                enable = true;
                efiSupport = true;
                efiInstallAsRemovable = true;
                configurationLimit = cfg.options.generations;
              };
              efi.canTouchEfiVariables = false;
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
