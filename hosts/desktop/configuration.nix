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

    ./../../modules/home/packages.nix 
    ./../../modules/home/programs/git.nix
    ./../../modules/home/programs/zsh.nix
    ./../../modules/home/programs/tmux.nix
    ./../../modules/home/programs/alacritty.nix
    ./../../modules/home/programs/neovim.nix
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    ./programs/aerospace.nix
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    ./programs/hyprland.nix
  ];

  # ===== HOST IDENTIFICATION =====
  networking.hostName = hostname;

  # ===== BOOT & KERNEL CONFIGURATION =====
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
  };

  # ===== SYSTEM VERSION =====
  system.stateVersion = "25.05";
}
