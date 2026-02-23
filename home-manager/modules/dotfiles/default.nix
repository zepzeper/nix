{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.dotfiles;
  dotfilesDir = "${config.home.homeDirectory}/personal/nix/dotfiles";
in {
  options.modules.dotfiles = {
    enable = lib.mkEnableOption "dotfiles symlinks";
    nvim = lib.mkEnableOption "neovim configuration + package";
    hypr = lib.mkEnableOption "hyprland configuration";
    ghostty = lib.mkEnableOption "ghostty configuration";
    tmux = lib.mkEnableOption "tmux configuration";
    waybar = lib.mkEnableOption "waybar configuration";
    walker = lib.mkEnableOption "walker configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf cfg.nvim [
      pkgs.neovim
    ];

    xdg.configFile = lib.mkMerge [
      (lib.mkIf cfg.nvim {
        "nvim" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nvim";
          recursive = true;
        };
      })
      (lib.mkIf cfg.hypr {
        "hypr" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/hypr";
          recursive = true;
        };
      })
      (lib.mkIf cfg.ghostty {
        "ghostty" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/ghostty";
          recursive = true;
        };
      })
      (lib.mkIf cfg.waybar {
        "waybar" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/waybar";
          recursive = true;
        };
      })
      (lib.mkIf cfg.walker {
        "walker" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/walker";
          recursive = true;
        };
      })
    ];

    home.file = lib.mkMerge [
      (lib.mkIf cfg.tmux {
        ".tmux.conf" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/tmux/.tmux.conf";
        };
      })
    ];
  };
}
