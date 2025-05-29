{ inputs, config, lib, pkgs, ... }:

{
  # ===== HYPRLAND CONFIGURATION =====
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Enable required services for Hyprland
  security.polkit.enable = true;
  
  # XDG Desktop Portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };
}
