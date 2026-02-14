{pkgs, ...}: {
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "zepzeper";
        email = "wouterschiedam98@gmail.com";
      };
    };
  };
}
