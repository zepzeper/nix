# (macOS only)
{ config, pkgs, lib, ... }:

{
  home.file.".aerospace.toml".source = "${config.home.homeDirectory}/.dotfiles/aerospace/aerospace.toml";
}
