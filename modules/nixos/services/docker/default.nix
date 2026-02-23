{
  lib,
  config,
  pkgs,
  ...
}: let
    cfg = config.services;
in {
    options.services = {
        docker = lib.mkEnableOption "Docker virtualizations";
    };

    config = lib.mkIf cfg.docker {
      virtualisation.docker.enable = true;
    };
}
