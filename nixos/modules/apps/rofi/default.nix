{ config, pkgs, ... }:

{
  # Install Rofi and related packages
  environment.systemPackages = with pkgs; [
    rofi
  ];
}
