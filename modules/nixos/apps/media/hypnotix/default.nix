{
  config,
  lib,
  pkgs,
  ...
}: let
    cfg = config.apps.media;
in {

options.apps.media = {
    hypnotix = lib.mkEnableOption "IPTV player";
};

config = lib.mkIf cfg.hypnotix {
  environment.systemPackages = with pkgs; [
    hypnotix
  ];
};

}
