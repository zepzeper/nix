# staging: a Hetzner Cloud server (x86) to test Kodai on; the site over the
# tailnet only. Its configuration follows main by itself (a merged change is
# live within minutes); Kodai's own CI deploys the application onto it.
# Creating and installing it, step by step: staging.md next to this file.
# Until it is installed its hardware file does not exist and is simply not
# imported.
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
        options.ipv6 = "2a01:4f9:c015:8b63::1/64";
      };

      tailscale.enable = true;
      kodai = {
        enable = true;
        # Points at its tailnet address (Cloudflare); HTTPS once the
        # cloudflare-dns secret exists (staging.md, step 7).
        options.domain = "staging.krugten.org";
      };

      # Follow main: look every 5 minutes, rebuild only when it moved.
      autoUpdate = {
        enable = true;
        options = {
          dates = "*:0/5";
          randomizedDelay = "0";
          onlyWhenChanged = true;
        };
      };
    };
  };
}
