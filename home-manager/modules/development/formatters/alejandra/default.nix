{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.formatters.alejandra;
in {
  options.modules.development.formatters.alejandra = {
    enable = lib.mkEnableOption "alejandra nix formatter";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      alejandra
    ];
  };
}
