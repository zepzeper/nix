{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.search;
in {
  imports = [
    ./ripgrep
  ];
}
