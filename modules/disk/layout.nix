{ inputs, ... }:
{
  # The standard disk layout, declared with disko so installing a machine is
  # one command and every machine is partitioned the same way:
  #
  #   ESP (1G, vfat, /boot)
  #   [LUKS "cryptroot"]           when options.encrypt is true
  #     BTRFS: @root /, @home /home, @nix /nix, @log /var/log, @swap
  #
  # With encryption the passphrase is asked for during install and at every
  # boot, typed with the keyboard layout of zep.locale (the installer's is
  # us). With options.tpm2 the disk can instead unlock through the TPM after
  # a short PIN, once `enroll-tpm-pin` (scripts/) has been run on the
  # machine (once: updates do not undo it); until then, or after too many
  # wrong PINs, it asks for the passphrase.
  flake.modules.nixos.disk-layout =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zep.disk;

      mount = [
        "compress=zstd"
        "noatime"
      ];

      btrfs = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "@root" = {
            mountpoint = "/";
            mountOptions = mount;
          };
          "@home" = {
            mountpoint = "/home";
            mountOptions = mount;
          };
          "@nix" = {
            mountpoint = "/nix";
            mountOptions = mount;
          };
          "@log" = {
            mountpoint = "/var/log";
            mountOptions = mount;
          };
        }
        // lib.optionalAttrs (cfg.options.swapSize != "") {
          "@swap" = {
            mountpoint = "/.swapvol";
            swap.swapfile.size = cfg.options.swapSize;
          };
        };
      };
    in
    {
      key = "zep#disk-layout";
      imports = [ inputs.disko.nixosModules.disko ];

      options.zep.disk = {
        enable = lib.mkEnableOption "the standard BTRFS disk layout (disko)";

        options = {
          device = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "/dev/nvme0n1";
            description = ''
              The disk to install on. Prefer a stable /dev/disk/by-id/ path.
              Everything on it is erased at install.
            '';
          };
          encrypt = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Put the BTRFS filesystem inside LUKS.";
          };
          recoveryKey = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              With encryption: also enroll a random recovery key at install
              (systemd-cryptenroll). disko shows it once, with a QR code, and
              waits - store it in the password manager. It opens the disk
              when the passphrase is forgotten.
            '';
          };
          tpm2 = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              With encryption: let the TPM unlock the disk after a PIN, and
              install `enroll-tpm-pin` to set that up on the machine.
            '';
          };
          swapSize = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "16G";
            description = "Size of a swap file on its own subvolume. Empty for none (zram is on anyway).";
          };
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.options.device != "";
            message = "zep.disk.options.device must name the disk to install on.";
          }
          {
            assertion = cfg.options.tpm2 -> cfg.options.encrypt && config.boot.initrd.systemd.enable;
            message = "zep.disk.options.tpm2 needs an encrypted disk and systemd in the initrd.";
          }
        ];

        boot.initrd.systemd.tpm2.enable = lib.mkIf cfg.options.tpm2 true;

        environment.systemPackages = lib.optional cfg.options.tpm2 (
          pkgs.writeShellApplication {
            name = "enroll-tpm-pin";
            text = builtins.readFile ./scripts/enroll-tpm-pin;
          }
        );

        disko.devices.disk.main = {
          type = "disk";
          inherit (cfg.options) device;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content =
                  if cfg.options.encrypt then
                    {
                      type = "luks";
                      name = "cryptroot";
                      settings = {
                        allowDiscards = true;
                        # Try the TPM (with its PIN) first; without an
                        # enrolled TPM key this falls back to the passphrase.
                        crypttabExtraOpts = lib.optional cfg.options.tpm2 "tpm2-device=auto";
                      };
                      enrollRecovery = cfg.options.recoveryKey;
                      content = btrfs;
                    }
                  else
                    btrfs;
              };
            };
          };
        };
      };
    };
}
