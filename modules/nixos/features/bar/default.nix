{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features;
in {
  options.features = {
    waybar = lib.mkEnableOption "Status bar (waybar)";
  };

  config = lib.mkIf cfg.waybar {
    environment.systemPackages = with pkgs; [
      waybar
    ];
  };
}
