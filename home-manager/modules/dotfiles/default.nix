{ config, lib, pkgs, ... }:
let
  # Path to dotfiles submodule (inside nix repo)
  dotfilesDir = "${config.home.homeDirectory}/personal/nix/dotfiles";
in
{
  # Neovim configuration
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nvim";
    recursive = true;
  };

  # Hyprland configuration
  xdg.configFile."hypr" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/hypr";
    recursive = true;
  };

  # Ghostty configuration
  xdg.configFile."ghostty" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/ghostty";
    recursive = true;
  };

  # Tmux configuration
  home.file.".tmux.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/tmux/.tmux.conf";
  };

  # Zsh configuration
  home.file.".zshrc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zsh/.zshrc";
  };
}
