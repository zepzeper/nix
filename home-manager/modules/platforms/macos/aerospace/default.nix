{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    aerospace
  ];
  
  home.file = {
    ".config/aerospace/aerospace.toml" = {
      source = "/Users/zepzeper/.dotfiles/aerospace/aerospace.toml";
    };
  };
}
