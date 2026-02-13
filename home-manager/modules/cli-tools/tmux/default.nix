{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tmux
  ];

  programs.zsh.shellAliases = {
    ta = "tmux attach-session -t";
    ts = "tmux new-session -s";
  };
}
