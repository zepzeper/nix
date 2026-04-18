{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.shell;
in {
  home.packages = with pkgs; [
    runelite
  ];
}
