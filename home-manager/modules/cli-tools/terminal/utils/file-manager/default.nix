{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils.fileManager;
in {
  options.modules.cliTools.terminal.utils.fileManager = {
    enable = lib.mkEnableOption "file manager (walker)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      walker
    ];
  };
}
