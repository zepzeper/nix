{
  config,
  lib,
  ...
}: let
  cfg = config.modules.cliTools;
in {
  imports = [
    ./git
    ./tmux
    ./screenshot
    ./recording
    ./terminal
  ];
}
