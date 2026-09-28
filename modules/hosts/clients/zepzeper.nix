# zepzeper, my desktop: niri + Noctalia on the unstable channel, RTX 3060 Ti, encrypted
# disk with a recovery key (forced by the workstation profile). Its hardware
# configuration is _zepzeper-hardware.nix, next to this file (generated at
# install with `nixos-generate-config --no-filesystems --show-hardware-config`).
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
      helium.enable = true;
      neovim.enable = true;

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

      disk.options.device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0NB56647A";

      users.options.admins.zepzeper.sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDb3F0fLHesNqOe3PTkPHfvuLnSjCz+8jP+wBa41SMcp zepzeper@zepzeper"
      ];
    };

    home-manager.users.zepzeper = {
      imports = [ config.flake.modules.homeManager."users/zepzeper" ];
      home.stateVersion = "26.11";
    };
  };
}
