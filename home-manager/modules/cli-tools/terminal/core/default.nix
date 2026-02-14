{pkgs, ...}: {
  home.packages = with pkgs; [
    ghostty
    fzf
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
