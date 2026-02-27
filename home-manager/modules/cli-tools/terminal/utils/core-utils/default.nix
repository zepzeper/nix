{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils;
in {
  options.modules.cliTools.terminal.utils = {
    coreUtils = lib.mkEnableOption "core CLI utilities (bat, jq, yq, pandoc)";
  };

  config = lib.mkIf cfg.coreUtils {
    home.packages = with pkgs; [
      bat
      jq
      yq
    ];
  };
}
