# hosts/desktop/configuration.nix
{ config, pkgs, lib, hostname, ... }:
let

in
{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/nixos/default.nix
    ../../modules/common/default.nix
  ];

  # ===== HOST IDENTIFICATION =====
  networking.hostName = hostname;

  # Disable display manager that auto-starts Hyprland
  services.greetd.enable = false;  # if using greetd
  services.xserver.displayManager.gdm.enable = false;  # if using GDM
  services.xserver.displayManager.sddm.enable = false;  # if using SDDM
  services.getty.autologinUser = "zepzeper";

  # ===== BOOT & KERNEL CONFIGURATION =====
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
  };

  # ===== SYSTEM VERSION =====
  system.stateVersion = "25.05";
}
