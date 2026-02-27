{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.formatters;
in {
  options.modules.development.formatters = {
    alejandra = lib.mkEnableOption "alejandra nix formatter";
  };

  config = lib.mkIf cfg.alejandra {
    home.packages = with pkgs; [
      alejandra
    ];
  };
}
