{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.utils;
in {
  options.modules.cliTools.terminal.utils = {
    notifications = lib.mkEnableOption "notification daemon (mako)";
  };

  config = lib.mkIf cfg.notifications {
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 5000;
        background-color = "#1e1e2e";
        font = "JetBrainsMono Nerd Font";
      };
    };
  };
}
