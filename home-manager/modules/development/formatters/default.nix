{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.formatters;
in {
  imports = [
    ./alejandra
    ./shfmt
  ];
}
