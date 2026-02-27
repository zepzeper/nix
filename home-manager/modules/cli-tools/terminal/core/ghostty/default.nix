{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal;
in {
  options.modules.cliTools.terminal = {
    ghostty = lib.mkEnableOption "ghostty terminal emulator";
  };

  config = lib.mkIf cfg.ghostty {
    home.packages = with pkgs; [
      ghostty
    ];

    programs.ghostty = {
      enable = true;
    };
  };
}
