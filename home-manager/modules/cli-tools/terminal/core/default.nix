{pkgs, ...}: {
  home.packages = with pkgs; [
    ghostty
    fzf
    alejandra
  ];

  programs.ghostty = {
    enable = true;
  };
}
