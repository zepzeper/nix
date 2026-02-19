# Desktop host configuration
# Hardware-specific settings for desktop workstation
{
  config,
  pkgs,
  lib,
  username,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";

  # Bootloader - desktop uses GRUB on NVMe
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" username];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
  };

  # Nixpkgs
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [inputs.nur.overlays.default];
  };

  # Desktop packages
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    blueman
    cachix
    wl-clipboard
    playerctl
    gparted
    polkit_gnome
    cudaPackages.cudatoolkit
    home-manager
  ];

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable nix-ld for running non-Nix binaries
  programs.nix-ld.enable = true;

  # Auto-upgrade
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    allowReboot = false;
  };

  # Additional drives
  fileSystems."/run/media/${username}/hdd" = {
    device = "/dev/disk/by-uuid/938f2c14-62a8-41e3-b67b-dd8785881bbd";
    fsType = "ext4";
    options = ["nosuid" "nodev" "nofail" "x-gvfs-show"];
  };
}
