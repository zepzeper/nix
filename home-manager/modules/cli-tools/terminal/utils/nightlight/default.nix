{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils;
in {
  options.modules.cliTools.terminal.utils = {
    nightlight = lib.mkEnableOption "blue light filter (hyprsunset)";
  };

  config = lib.mkIf cfg.nightlight {
    home.packages = with pkgs; [
      hyprsunset
    ];
  };
}
