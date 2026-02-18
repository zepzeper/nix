{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Make UWSM available system-wide
  environment.systemPackages = with pkgs; [
    uwsm
  ];

  # Display manager configuration
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "hyprland";
  };

  # Disable all desktop environments
  services.desktopManager = {
    plasma6.enable = false;
    gnome.enable = false;
  };

  services.xserver = {
    desktopManager = {
      xfce.enable = false;
    };
    windowManager = {
      i3.enable = false;
      awesome.enable = false;
    };
    enable = false; # disable X11 entirely
  };

  # Enable Hyprland as the primary Wayland compositor
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # Enable UWSM systemd integration
  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };
  };
}
