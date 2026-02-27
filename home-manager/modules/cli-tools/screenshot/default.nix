{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools;
in {
  options.modules.cliTools = {
    screenshot = lib.mkEnableOption "screenshot tools";
  };

  config = lib.mkIf cfg.screenshot {
    home.packages = with pkgs; [
      grim
      slurp
      satty
      hyprshot
      wl-clipboard
    ];
  };
}
