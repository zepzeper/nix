{
  config,
  lib,
  ...
}: let
  cfg = config.modules.cliTools.terminal.core;
in {
  imports = [
    ./ghostty
    ./fzf
  ];
}
