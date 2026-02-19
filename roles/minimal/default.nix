# Minimal role - base system for all hosts
# This provides the absolute minimum for a functional NixOS system
{
  config,
  pkgs,
  lib,
  username,
  hostname,
  ...
}: {
  # Boot configuration (generic - override per-host for specific bootloader)
  #boot.loader.systemd-boot.enable = lib.mkDefault true;
  #boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Networking
  networking = {
    hostName = hostname;
    networkmanager.enable = lib.mkDefault true;
  };

  # Locale
  time.timeZone = lib.mkDefault "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Console keymap
  console.keyMap = lib.mkDefault "us";

  # Base packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    htop
    vim
    zsh
    sudo
    ssh-to-age
  ];

  # SSH server - allow password auth for initial setup
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  # Sudo configuration - allow wheel group with password
  security.sudo = {
    enable = true;
    wheelNeedsPassword = lib.mkDefault true;
  };

  # Users (generic - enable based on host config)
  # Password must be set per-host using initialPassword or hashedPassword
  users.users.${username} = {
    isNormalUser = true;
    description = lib.mkDefault username;
    group = "users";
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [];
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Nix settings
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  # System-wide zsh
  users.defaultUserShell = pkgs.zsh;
}
