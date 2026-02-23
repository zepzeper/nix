{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils.nightlight;
in {
  options.modules.cliTools.terminal.utils.nightlight = {
    enable = lib.mkEnableOption "blue light filter (hyprsunset)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprsunset
    ];
  };
}
