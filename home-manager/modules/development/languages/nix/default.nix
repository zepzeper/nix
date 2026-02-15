{ config, lib, pkgs, ... }:
let
  cfg = config.modules.development.languages.nix;
in {
  options.modules.development.languages.nix = {
    enable = lib.mkEnableOption "Nix development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
      nixfmt-rfc-style
      alejandra
      nix-tree
      nix-diff
      statix
      deadnix
    ];
  };
}
