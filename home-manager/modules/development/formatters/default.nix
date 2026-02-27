{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.formatters;
in {
  imports = [
    ./alejandra
    ./shfmt
  ];
}
