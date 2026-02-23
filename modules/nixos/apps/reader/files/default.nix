{
  lib,
  config,
  pkgs,
  ...
}: let
    cfg = config.apps.reader.files;
in {
  options.apps.reader.files = {
    nautilus = lib.mkEnableOption "File manager";
  };

  config = lib.mkIf cfg.nautilus {
      environment.systemPackages = with pkgs; [
        nautilus
      ];
  };
}
