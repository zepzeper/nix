{
  config,
  pkgs,
  ...
}: {
  # Install custom scripts to ~/.local/bin
  home.file = {
    # Nix scripts
    ".local/bin/nix-menu" = {
      source = ../../../scripts/nix-menu;
      executable = true;
    };

    ".local/bin/nix-shot" = {
      source = ../../../scripts/nix-shot;
      executable = true;
    };

    ".local/bin/nix-rec" = {
      source = ../../../scripts/nix-rec;
      executable = true;
    };

    ".local/bin/nix-launcher" = {
      source = ../../../scripts/nix-launcher;
      executable = true;
    };

    ".local/bin/nix-rebuild" = {
      source = ../../../scripts/nix-rebuild;
      executable = true;
    };

    # Misc scripts
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

    # System scripts
    ".local/bin/launch-or-focus" = {
      source = ../../../scripts/system/launch-or-focus;
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
  };

  # Ensure ~/.local/bin is in PATH
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Shell aliases for convenience
  programs.zsh.shellAliases = {
    rebuild = "nix-rebuild";
  };
}
