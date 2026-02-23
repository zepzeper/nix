{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils.coreUtils;
in {
  options.modules.cliTools.terminal.utils.coreUtils = {
    enable = lib.mkEnableOption "core CLI utilities (bat, jq, yq, pandoc)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bat
      jq
      yq
    ];
  };
}
