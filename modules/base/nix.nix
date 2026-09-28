{ inputs, ... }:
{
  # Nix itself: flakes, garbage collection, and the registry pinned to the
  # nixpkgs this flake is built from, so `nix shell nixpkgs#foo` on a machine
  # uses the same nixpkgs as its system.
  flake.modules.nixos.base-nix =
    { config, lib, ... }:
    let
      cfg = config.zep.nix;
    in
    {
      options.zep.nix = {
        enable = lib.mkEnableOption "Nix settings, garbage collection and registry pinning";

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

          registry.nixpkgs.flake = inputs.nixpkgs;
          nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
          channel.enable = false;
        };

        nixpkgs.config.allowUnfree = lib.mkDefault true;
      };
    };
}
