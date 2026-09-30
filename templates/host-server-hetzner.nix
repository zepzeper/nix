# Template: a Hetzner Cloud server (x86). Copy to
# modules/hosts/servers/<name>.nix and replace "server-hetzner" with the
# machine's name (its role: web, db, ...).
#
# The server profile: shell only, stable channel, unencrypted disk, no
# automatic updates; deployed from the desktop:
#   nixos-rebuild switch --flake .#<name> --target-host <name> --ask-sudo-password
# Installed with nixos-anywhere (README, "Hetzner Cloud servers"; step by
# step: modules/hosts/servers/staging.md), which also writes the hardware
# file next to this one. It is imported once it exists, so this file can be
# pushed before the install.
{ config, lib, ... }:
{
  flake.modules.nixos."hosts/server-hetzner" = {
    imports = [
      config.flake.modules.nixos.profiles-server
      # Me as admin (SSH keys from modules/users/zepzeper/authorized_keys),
      # with my Home Manager setup and secrets.
      config.flake.modules.nixos."users/zepzeper"
    ]
    ++ lib.optional (builtins.pathExists ./_server-hetzner-hardware.nix) ./_server-hetzner-hardware.nix;

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05"; # the release it was installed with; never change

    zep = {
      hetznerCloud = {
        enable = true;
        # Cloud Console -> the server -> Networking: its IPv6 /64, with ::1.
        options.ipv6 = "2a01:4f8:CHANGE-ME::1/64";
      };

      # Reachable over the tailnet too; log in once with `tailscale up`.
      tailscale.enable = true;
    };
  };
}
