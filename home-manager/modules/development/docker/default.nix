{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    docker-compose
  ];
}
