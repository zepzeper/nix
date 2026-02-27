{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils;
in {
  options.modules.cliTools.terminal.utils = {
    monitoring = lib.mkEnableOption "system monitoring (btop)";
  };

  config = lib.mkIf cfg.monitoring {
    home.packages = with pkgs; [
      btop
    ];
  };
}
