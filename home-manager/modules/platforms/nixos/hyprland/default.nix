{
  config,
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      exec-once = [ "hyprpaper" ];
      
      # General settings with Rose Pine colors
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(c4a7e7ee) rgba(f6c177ee) 45deg";  # Rose Pine purple to gold gradient
        "col.inactive_border" = "rgba(6e6a86aa)";  # Rose Pine muted
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
        # Add these cursor-related settings
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vfr = true;
        vrr = 0;
      };
      
      # Add cursor settings
      cursor = {
        no_hardware_cursors = true;
        enable_hyprcursor = false;
        hide_on_key_press = false;
      };
      
      # Environment variables for NVIDIA - expanded for stability
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
        # Additional stability env vars
        "NVIDIA_EXPERIMENTAL_EXPLICIT_SYNC,1"
        "WLR_DRM_NO_ATOMIC,1"
        "WLR_RENDERER,gles2"
        "__GL_GSYNC_ALLOWED,0"
        "__GL_VRR_ALLOWED,0"
      ];
      
      # Key bindings
      bind = [
        # App launchers
        "$mod, Return, exec, alacritty"
        "$mod, Space, exec, rofi -show drun"
        "$mod, C, exec, rofi -show calc"
        "$mod, B, exec, brave"
        "$mod, P, exec, spotify"
        "$mod, G, exec, gimp"
        
        # Window management
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, V, togglefloating"
        "$mod, J, togglesplit"
        "$mod, F, fullscreen"
        
        # Focus movement
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        
        # Window movement
        "$mod ALT, h, movewindow, l"
        "$mod ALT, l, movewindow, r"
        "$mod ALT, k, movewindow, u"
        "$mod ALT, j, movewindow, d"
        
        # Workspace switching
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        
        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
      ];
    };
  };
  
  # Hyprpaper service for wallpapers (only on Linux)
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        "~/Wallpapers/wall-1.jpg"
      ];
      wallpaper = [
        ",~/Wallpapers/wall-1.jpg"
      ];
    };
  };
}
