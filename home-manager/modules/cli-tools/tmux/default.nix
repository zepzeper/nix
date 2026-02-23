{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.tmux;
in {
  options.modules.cliTools.tmux = {
    enable = lib.mkEnableOption "tmux tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      tmux
    ];
  };
}
