{
  config,
  lib,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils;
in {
  imports = [
    ./monitoring
    ./file-manager
    ./notifications
    ./bluetooth
    ./nightlight
    ./core-utils
  ];
}
