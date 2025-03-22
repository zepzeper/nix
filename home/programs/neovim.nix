{ config, pkgs, ... }:

let
   nvimConfig = "${config.home.homeDirectory}/.dotfiles/nvim";
in
{
  # Set the configuration directory for Neovim
  home.file.".config/nvim" = {
    source = nvimConfig;
    target = ".config/nvim";
  };

  programs.neovim = {
    enable = true;
  };
}

