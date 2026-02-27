{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    nix = lib.mkEnableOption "Nix development";
  };

  config = lib.mkIf cfg.nix {
    home.packages = with pkgs; [
      nil
      alejandra
      nix-tree
      nix-diff
      statix
      deadnix
    ];
  };
}
