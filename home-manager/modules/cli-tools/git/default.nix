{pkgs, ...}: {
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;

    userName = "zepzeper";
    userEmail = "wouterschiedam98@gmail.com";
  };
}
