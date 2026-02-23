{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.screenshot;
in {
  options.modules.cliTools.screenshot = {
    enable = lib.mkEnableOption "screenshot tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
      slurp
      satty
      hyprshot
      wl-clipboard
    ];
  };
}
