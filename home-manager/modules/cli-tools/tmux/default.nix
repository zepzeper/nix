{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools;
in {
  options.modules.cliTools = {
    tmux = lib.mkEnableOption "tmux tools";
  };

  config = lib.mkIf cfg.tmux {
    home.packages = with pkgs; [
      tmux
    ];
  };
}
