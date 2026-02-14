{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ghostty
    fzf
  ];

  programs.ghostty = {
    enable = true;
  };

}
