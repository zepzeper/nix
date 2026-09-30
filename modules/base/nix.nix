{ inputs, ... }:
{
  # Nix itself: flakes, garbage collection, and `pkgs.unstable` for the odd
  # package a stable machine needs newer.
  #
  # The registry and NIX_PATH are not set here: nixpkgs' own
  # nixpkgs.flake.setFlakeRegistry/setNixPath pin them to whichever channel
  # the host was built from, so `nix shell nixpkgs#foo` matches the system.
  flake.modules.nixos.base-nix =
    {
      config,
      lib,
      pkgs,
      hostConfig,
      ...
    }:
    let
      cfg = config.zep.nix;
    in
    {
      key = "zep#base-nix";
      options.zep.nix = {
        enable = lib.mkEnableOption "Nix settings and garbage collection";

        options.trustAdmins = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Make wheel a trusted Nix user, so an admin can push unsigned
            closures with `nixos-rebuild --target-host`. That is root without
            a password (a trusted user can import arbitrary store paths), so
            only machines that are deployed to remotely - servers - turn it on.
          '';
        };

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
            trusted-users = lib.mkIf cfg.options.trustAdmins [
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

        # Every machine is managed from a git repository (this one).
        environment.systemPackages = [ pkgs.git ];

        # nh: `nh os switch` builds, shows what changes, and switches. A host
        # sets where its clone of this repository is (programs.nh.flake), so
        # the path can be left out.
        programs.nh.enable = true;

        nixpkgs = {
          config.allowUnfree = lib.mkDefault true;

          # environment.systemPackages = [ pkgs.unstable.<name> ];
          # On an unstable host that is simply pkgs itself.
          overlays = [
            (final: _: {
              unstable =
                if hostConfig.channel == "unstable" then
                  final
                else
                  import inputs.nixpkgs-unstable {
                    inherit (final.stdenv.hostPlatform) system;
                    inherit (final) config;
                  };
            })
          ];
        };
      };
    };
}
