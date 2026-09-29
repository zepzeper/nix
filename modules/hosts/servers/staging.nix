# staging: a Hetzner Cloud server (x86) to test Kodai on, reached over the
# tailnet only. Not installed yet: create it in the Cloud Console, then
# install and deploy as in modules/services/kodai/kodai.md. Until then its
# hardware file does not exist and is simply not imported.
{ config, lib, ... }:
{
  flake.modules.nixos."hosts/staging" = {
    imports = [
      config.flake.modules.nixos.profiles-server
      config.flake.modules.nixos."users/zepzeper"
    ]
    ++ lib.optional (builtins.pathExists ./_staging-hardware.nix) ./_staging-hardware.nix;

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05"; # the release it is installed with; never change

    zep = {
      hetznerCloud = {
        enable = true;
        # Cloud Console -> the server -> Networking: its IPv6 /64, with ::1.
        # options.ipv6 = "2a01:4f8:...::1/64";
      };

      tailscale.enable = true;
      kodai.enable = true;
    };
  };
}
