# hosts/desktop/home.nix
{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home
  ];

  # Desktop-specific home configuration
  home.packages = with pkgs; [
    # Desktop-specific applications
    firefox
    kitty
    # Add other desktop-specific packages here
  ];

  # Desktop-specific program configurations
  programs = {
    # Add desktop-specific program configs here
  };

  # Linux-specific services or configurations
  services = {
    # Add any desktop-specific services here
  };
}
