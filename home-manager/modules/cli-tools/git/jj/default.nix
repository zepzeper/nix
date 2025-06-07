{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    jujutsu
  ];

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Zepzeper";
        email = "wouterschiedam98@gmail.com";
      };
    };
  };

  programs.zsh = {
    shellAliases = {
      jl = "jj log";
      js = "jj st";
    };
  };
}
