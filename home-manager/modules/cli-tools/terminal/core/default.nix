{pkgs, ...}: {
  home.packages = with pkgs; [
    ghostty
    fzf
    ripgrep
    alejandra
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ghostty = {
    enable = true;
  };
}
