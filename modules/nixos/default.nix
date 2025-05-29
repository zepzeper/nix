{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./services.nix
    ./gaming.nix

    ./hardware/nvidia.nix
    ./hardware/rgb.nix

    ./desktop/hyprland.nix
  ];
  # ===== NETWORKING =====
  networking.networkmanager.enable = true;
}
