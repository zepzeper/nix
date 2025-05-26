# home/zepzeper-nixos.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./programs/zsh-nixos.nix
    ./programs/tmux-nixos.nix
    ./programs/alacritty.nix
    ./programs/neovim.nix
    ./programs/ssh.nix
    ./packages-nixos.nix
  ];

  # Basic home-manager configuration
  home.username = "zepzeper";
  home.homeDirectory = "/home/zepzeper";
  home.stateVersion = "23.11";
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Environment variables (adapted for Linux)
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    
    # Go configuration
    GOPATH = "$HOME/go";
    
    # Custom scripts folder
    PATH = "$PATH:$HOME/scripts:$GOPATH/bin";
  };

  # XDG configuration for proper Linux desktop integration
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # GTK theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "zepzeper";  # Replace with your actual git username
    userEmail = "wouterschiedam98@gmail.com";  # Replace with your email
  };
}
