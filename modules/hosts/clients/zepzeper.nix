# zepzeper, my desktop: niri + Noctalia on the unstable channel, RTX 3060 Ti, encrypted
# disk with a recovery key (forced by the workstation profile). Its hardware
# configuration is _zepzeper-hardware.nix, next to this file (generated at
# install with `nixos-generate-config --no-filesystems --show-hardware-config`).
{ config, ... }:
{
  # My own machine: the unstable channel.
  zep.hosts.zepzeper.channel = "unstable";

  flake.modules.nixos."hosts/zepzeper" =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.nixos.profiles-workstation
        config.flake.modules.nixos."users/zepzeper"
        ./_zepzeper-hardware.nix
      ];

      nixpkgs.hostPlatform = "x86_64-linux";
      # The release this machine was first installed with - unstable, so 26.11
      # (the 26.05 installer ISO does not matter). Never change it afterwards.
      system.stateVersion = "26.11";

      zep = {
        desktop.options.environment = "niri";
        helium.enable = true;
        neovim.enable = true;
        devTools.enable = true;
        steam.enable = true;
        spotify.enable = true;
        localsend.enable = true;

        # Logged in once by hand (`tailscale up`); the auth key secret is
        # for servers.
        tailscale.enable = true;

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
      };

      # This repository's clone here: `nh os switch` without a path.
      programs.nh.flake = "/home/zepzeper/personal/nix";

      environment.systemPackages = with pkgs; [
        vlc
        iptvnator
        bitwarden-desktop
        gimp
      ];
    };
}
