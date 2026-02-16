{
  config,
  pkgs,
  ...
}: {
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
      # Custom tmux sessionizer keybinding
      bindkey -s '^f' "$HOME/.local/bin/tmux-sessionizer\n"
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
}
