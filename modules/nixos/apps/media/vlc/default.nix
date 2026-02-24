{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.apps.media;
in {
  options.apps.media = {
    vlc = lib.mkEnableOption "Media player";
  };

  config = lib.mkIf cfg.vlc {
    environment.systemPackages = with pkgs; [
      vlc
    ];
  };
}
