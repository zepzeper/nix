{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.extra;
in {
  options.modules.cliTools.terminal.extra = {
    enable = lib.mkEnableOption "extra terminal tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      opencode
    ];
  };
}
