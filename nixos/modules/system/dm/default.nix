{
  config,
  pkgs,
  ...
}:
{
  # Display manager configuration
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "hyprland";
  };
  
  # Explicitly disable all desktop environments
  services.desktopManager = {
    plasma6.enable = false;
  };
  services.xserver = {
    desktopManager = {
      plasma5.enable = false;
      gnome.enable = false;
      xfce.enable = false;
    };
    windowManager = {
      # Disable X11 window managers too
      i3.enable = false;
      awesome.enable = false;
    };
  };
  
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    # Ensure it's the primary compositor
    xwayland.enable = true;
  };
  
  services.xserver.enable = false;
}
