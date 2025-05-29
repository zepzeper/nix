# home/desktop-manager.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ../hosts/desktop/hardware-configuration.nix
    ./desktop-packages.nix
    ./programs/alacritty.nix
    ./programs/tmux.nix
    ./programs/zsh.nix
    ./programs/neovim.nix
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
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "zepzeper";  # Replace with your actual git username
    userEmail = "wouterschiedam98@gmail.com";  # Replace with your email
  };

  # Fonts configuration
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Hyprland config
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      exec-once = [ "hyprpaper" ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(794494aa)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      
      # Decoration settings
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      # Misc settings
      misc = {
        force_default_wallpaper = true;
      };

      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,nvidia"
        "GSM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];
      bind = [
        # App launchers
        "$mod, Return, exec, alacritty"
        "$mod, Space, exec, rofi -show drun"
        "$mod, B, exec, firefox"

        # Window management
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"
        "$mod, F, fullscreen"

        # Focus movement
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        "$mod ALT, h, movewindow, l"   # Move left
        "$mod ALT, l, movewindow, r"  # Move right
        "$mod ALT, k, movewindow, u"     # Move up
        "$mod ALT, j, movewindow, d"   # Move down

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;

      preload = [
        "~/Wallpapers/bay.JPG"
      ];
      wallpaper = [
        ",~/Wallpapers/bay.JPG"
      ];
    };
  };
}
