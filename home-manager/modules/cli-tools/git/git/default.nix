{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    userName = "Zepzeper";
    userEmail = "wouterschiedam98@gmail.com";
  };
}
