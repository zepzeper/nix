{
  config,
  lib,
  ...
}: let
  cfg = config.modules.cliTools.terminal;
in {
  imports = [
    ./core
    ./utils
  ];
}
