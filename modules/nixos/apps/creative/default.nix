{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.apps.creative;
in {
  options.apps.creative = {
    gimp = lib.mkEnableOption "GIMP photoshop alternative";
  };

  config = lib.mkIf cfg.gimp {
    environment.systemPackages = with pkgs; [
      gimp
    ];
  };
}
