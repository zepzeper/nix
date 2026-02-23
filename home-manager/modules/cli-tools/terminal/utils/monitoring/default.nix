{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils.monitoring;
in {
  options.modules.cliTools.terminal.utils.monitoring = {
    enable = lib.mkEnableOption "system monitoring (btop)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      btop
    ];
  };
}
