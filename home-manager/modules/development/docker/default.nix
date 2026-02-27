{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development;
in {
  options.modules.development = {
    docker = lib.mkEnableOption "docker support";
  };

  config = lib.mkIf cfg.docker {
    home.packages = with pkgs; [
      docker-compose
    ];
  };
}
