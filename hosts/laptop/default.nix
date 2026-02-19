# Laptop host configuration
# Hardware-specific settings for laptop
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

  # Laptop typically uses systemd-boot
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Power management for laptop
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
    };
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

  # Laptop packages
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    blueman
    cachix
    wl-clipboard
    playerctl
    polkit_gnome
    home-manager
    powertop
  ];

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable nix-ld
  programs.nix-ld.enable = true;

  # Auto-upgrade
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    allowReboot = false;
  };

  # Laptop-specific: fingerprint reader (if available)
  # services.fprintd.enable = lib.mkDefault false;
}
