{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.scripts;
in {
  options.modules.scripts = {
    enable = lib.mkEnableOption "custom scripts";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".local/bin/nix-rebuild" = {
        source = ../../../scripts/nix-rebuild;
        executable = true;
      };

      ".local/bin/nix-deploy-anywhere" = {
        source = ../../../scripts/nix-deploy-anywhere;
        executable = true;
      };

      ".local/bin/cheat" = {
        source = ../../../scripts/misc/cheat;
        executable = true;
      };

      ".local/bin/llm" = {
        source = ../../../scripts/misc/llm;
        executable = true;
      };

      ".local/bin/pomo-run" = {
        source = ../../../scripts/misc/pomo-run;
        executable = true;
      };

      ".local/bin/tmux-sessionizer" = {
        source = ../../../scripts/misc/tmux-sessionizer;
        executable = true;
      };

      ".local/bin/launch-or-focus" = {
        source = ../../../scripts/system/launch-or-focus;
        executable = true;
      };

      ".local/bin/launch-or-focus-tui" = {
        source = ../../../scripts/system/launch-or-focus-tui;
        executable = true;
      };

      ".local/bin/launch-tui" = {
        source = ../../../scripts/system/launch-tui;
        executable = true;
      };

      ".local/bin/launch-webapp" = {
        source = ../../../scripts/system/launch-webapp;
        executable = true;
      };

      ".local/bin/launch-wifi" = {
        source = ../../../scripts/system/launch-wifi;
        executable = true;
      };

      ".local/bin/launch-bluetooth" = {
        source = ../../../scripts/system/launch-bluetooth;
        executable = true;
      };

      ".local/bin/launch-audio" = {
        source = ../../../scripts/system/launch-audio;
        executable = true;
      };

      ".local/bin/launch-screenshot" = {
        source = ../../../scripts/system/launch-screenshot;
        executable = true;
      };

      ".local/bin/launch-screenrecorder" = {
        source = ../../../scripts/system/launch-screenrecorder;
        executable = true;
      };

      ".local/bin/is-screen-recording" = {
        source = ../../../scripts/system/is-screen-recording;
        executable = true;
      };

      ".local/bin/launch-menu" = {
        source = ../../../scripts/system/launch-menu;
        executable = true;
      };

      ".local/bin/launch-nightlight" = {
        source = ../../../scripts/system/launch-nightlight;
        executable = true;
      };
    };

    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    programs.zsh.shellAliases = {
      rebuild = "nix-rebuild";
      deploy-anywhere = "nix-deploy-anywhere";
    };
  };
}
