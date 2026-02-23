{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.docker;
in {
  options.modules.development.docker = {
    enable = lib.mkEnableOption "docker support";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      docker-compose
    ];
  };
}
