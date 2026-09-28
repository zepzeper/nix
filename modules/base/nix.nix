{ inputs, ... }:
{
  # Nix itself: flakes, garbage collection, and `pkgs.unstable` for the odd
  # package a stable machine needs newer.
  #
  # The registry and NIX_PATH are not set here: nixpkgs' own
  # nixpkgs.flake.setFlakeRegistry/setNixPath pin them to whichever channel
  # the host was built from, so `nix shell nixpkgs#foo` matches the system.
  flake.modules.nixos.base-nix =
    { config, lib, ... }:
    let
      cfg = config.zep.nix;
    in
    {
      options.zep.nix = {
        enable = lib.mkEnableOption "Nix settings and garbage collection";

        options.keepGenerationsDays = lib.mkOption {
          type = lib.types.ints.positive;
          default = 14;
          description = "Generations older than this many days are garbage collected weekly.";
        };
      };

      config = lib.mkIf cfg.enable {
        nix = {
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            # Admins in wheel can copy closures to this machine, which
            # `nixos-rebuild --target-host` needs.
            trusted-users = [
              "root"
              "@wheel"
            ];
          };

          gc = {
            automatic = lib.mkDefault true;
            dates = lib.mkDefault "weekly";
            options = "--delete-older-than ${toString cfg.options.keepGenerationsDays}d";
          };

          # Deduplicate the store on a timer rather than during every build
          # (auto-optimise-store), which slows builds down.
          optimise.automatic = lib.mkDefault true;

          channel.enable = false;
        };

        nixpkgs = {
          config.allowUnfree = lib.mkDefault true;

          # environment.systemPackages = [ pkgs.unstable.<name> ];
          # On an unstable host this is the same nixpkgs again.
          overlays = [
            (final: _: {
              unstable = import inputs.nixpkgs-unstable {
                inherit (final.stdenv.hostPlatform) system;
                inherit (final) config;
              };
            })
          ];
        };
      };
    };
}
