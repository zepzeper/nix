{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils;
in {
  options.modules.cliTools.terminal.utils = {
    fileManager = lib.mkEnableOption "file manager (walker)";
  };

  config = lib.mkIf cfg.fileManager {
    home.packages = with pkgs; [
      walker
    ];
  };
}
