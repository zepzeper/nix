{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktopSettings.bar;
in {
  options.desktopSettings = {
    bar = lib.mkEnableOption "status bar (waybar)";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      waybar
    ];
  };
}
