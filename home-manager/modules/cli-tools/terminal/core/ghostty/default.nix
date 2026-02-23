{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.ghostty;
in {
  options.modules.cliTools.terminal.ghostty = {
    enable = lib.mkEnableOption "ghostty terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ghostty
    ];

    programs.ghostty = {
      enable = true;
    };
  };
}
