# Display Manager and Window Compositor
# Configures Hyprland with SDDM on Wayland
{
  config,
  pkgs,
  lib,
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

  # Disable other desktop environments
  services.desktopManager = {
    plasma6.enable = lib.mkDefault false;
    gnome.enable = lib.mkDefault false;
  };

  services.xserver = {
    desktopManager = {
      xfce.enable = lib.mkDefault false;
    };
    windowManager = {
      i3.enable = lib.mkDefault false;
      awesome.enable = lib.mkDefault false;
    };
    enable = false; # Wayland by default
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
