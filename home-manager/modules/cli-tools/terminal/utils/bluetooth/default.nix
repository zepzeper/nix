{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils.bluetooth;
in {
  options.modules.cliTools.terminal.utils.bluetooth = {
    enable = lib.mkEnableOption "bluetooth TUI (bluetui)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bluetui
    ];
  };
}
