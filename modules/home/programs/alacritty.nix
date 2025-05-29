{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile "${config.home.homeDirectory}/.dotfiles/alacritty/alacritty.toml");
  };
}
