{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.shell;
in {
  options.modules.shell = {
    zsh = lib.mkEnableOption "zsh configuration";
  };

  config = lib.mkIf cfg.zsh {
    programs.zsh = {
      enable = true;

      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      shellAliases = {
        cat = "bat --paging=never";
      };

      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      initContent = ''
        bindkey -s '^f' "$HOME/.local/bin/tmux-sessionizer\n"

        PROMPT="[%m] $PROMPT"
      '';

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "fzf"
          "docker"
          "sudo"
        ];
      };
    };
  };
}
