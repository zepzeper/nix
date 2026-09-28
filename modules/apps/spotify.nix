{ inputs, ... }:
{
  # Spotify, themed with Spicetify: the Comfy theme (the one Noctalia's docs
  # suggest), in its own dark colour scheme. Built with the theme applied, so
  # there is nothing to run by hand and it survives Spotify updates.
  #
  # Themes, colour schemes and extensions: https://gerg-l.github.io/spicetify-nix/
  flake.modules.nixos.apps-spotify =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      key = "zep#apps-spotify";
      imports = [ inputs.spicetify-nix.nixosModules.default ];

      options.zep.spotify.enable = lib.mkEnableOption "Spotify, themed with Spicetify";

      config = lib.mkIf config.zep.spotify.enable {
        programs.spicetify = {
          enable = true;
          theme = spicePkgs.themes.comfy;
          colorScheme = "Comfy";
        };
      };
    };
}
