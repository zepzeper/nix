# zepzeper, my desktop: niri + Noctalia on the unstable channel, RTX 3060 Ti, encrypted
# disk with a recovery key (forced by the workstation profile).
#
# Two things are filled in on the machine itself, from the installer:
#
# 1. The disk to install on, below: `ls -l /dev/disk/by-id/` and pick the
#    NVMe drive's nvme-... name (not a -part name, not the HDD).
# 2. Its hardware configuration, next to this file:
#      nixos-generate-config --no-filesystems --show-hardware-config \
#        > modules/hosts/clients/_zepzeper-hardware.nix
#    It is imported automatically once it exists. Commit it after the
#    install.
{ config, lib, ... }:
{
  # My own machine: the unstable channel.
  zep.hosts.zepzeper.channel = "unstable";

  flake.modules.nixos."hosts/zepzeper" = {
    imports = [
      config.flake.modules.nixos.profiles-workstation
    ]
    ++ lib.optional (builtins.pathExists ./_zepzeper-hardware.nix) ./_zepzeper-hardware.nix;

    nixpkgs.hostPlatform = "x86_64-linux";
    # The release this machine was first installed with - unstable, so 26.11
    # (the 26.05 installer ISO does not matter). Never change it afterwards.
    system.stateVersion = "26.11";

    zep = {
      desktop.options.environment = "niri";

      graphics.options = {
        gpu = "nvidia";
        nvidiaGeneration = "turing-or-newer"; # RTX 3060 Ti (Ampere)
      };

      # Monitors (names: `niri msg outputs`). Empty: niri picks scale itself.
      # niri.options.outputs = ''
      #   output "DP-1" {
      #       scale 1.6
      #   }
      # '';

      disk.options.device = "/dev/disk/by-id/CHANGE-ME";

      users.options.admins.zepzeper.sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvm8nVnf89bkeOP1LvckqBK8d41fwXcDCKi4VTjmIwH"
      ];
    };

    home-manager.users.zepzeper.home.stateVersion = "26.11";
  };
}
