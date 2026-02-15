{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

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
