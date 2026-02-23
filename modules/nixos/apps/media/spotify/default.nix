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
    spotify = lib.mkEnableOption "Music player";
};

config = lib.mkIf cfg.spotify {
  environment.systemPackages = with pkgs; [
    spotify
  ];
};
}
