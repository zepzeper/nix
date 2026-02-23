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
    localsend = lib.mkEnableOption "Air drop alternative";
};

config = lib.mkIf cfg.localsend {
  environment.systemPackages = with pkgs; [
    localsend
  ];
};
}
