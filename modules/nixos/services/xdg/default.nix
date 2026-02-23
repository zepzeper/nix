{
  lib,
  config,
  pkgs,
  ...
}: let
    cfg = config.services;
in {
    options.services = {
        xdg = lib.mkEnableOption "XDG configuration";
    };

  config = lib.mkIf cfg.xdg {
      # Make the binary available system-wide
      environment.systemPackages = with pkgs; [
        xdg-terminal-exec
      ];

      # Enable xdg-terminal-exec support
      xdg.terminal-exec.enable = true;

      # Optional: set preferred terminals
      xdg.terminal-exec.settings = {
        default = [
          "ghostty.desktop"
          "alacritty.desktop"
          "xterm.desktop"
        ];
      };
  };
}
