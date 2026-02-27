{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils;
in {
  options.modules.cliTools.terminal.utils = {
    bluetooth = lib.mkEnableOption "bluetooth TUI (bluetui)";
  };

  config = lib.mkIf cfg.bluetooth {
    home.packages = with pkgs; [
      bluetui
    ];
  };
}
