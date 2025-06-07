{ config, pkgs, ...}:
{
  home.packages = with pkgs; [
    alacritty
  ];

  programs.alacritty = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile "${config.home.homeDirectory}/.dotfiles/alacritty/alacritty.toml");
  };

}
