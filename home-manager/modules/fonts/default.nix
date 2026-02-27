{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules;
in {
  options.modules = {
    fonts = lib.mkEnableOption "fonts configuration";
  };

  config = lib.mkIf cfg.fonts {
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig = {
      enable = true;
    };
  };
}
