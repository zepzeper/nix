# home/zepzeper.nix - Main configuration file
{ config, pkgs, lib, ... }:

{
  imports = [
    ./programs/zsh.nix
    ./programs/tmux.nix
    ./programs/alacritty.nix
    ./programs/neovim.nix
    ./programs/aerospace.nix
    ./programs/ssh.nix
    ./packages.nix
  ];

  # Basic home-manager configuration
  home.username = "zepzeper";
  home.homeDirectory = "/Users/zepzeper";
  home.stateVersion = "23.11";
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
