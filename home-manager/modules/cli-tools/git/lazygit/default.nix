{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    lazygit
  ];

  programs.lazygit = {
    enable = true;
    settings = {
      gui.authorColors = {
        "Zepzeper" = "blue";
      };
    };
  };

  programs.zsh = {
    shellAliases = {
      lg = "lazygit";
    };
  };
}
