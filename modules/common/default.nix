{ inputs, lib, config, pkgs, username, ... }:

{
  imports = [
    ./users.nix
  ];

  # ===== NIX CONFIGURATION =====
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
  };

  # ===== PACKAGE CONFIGURATION =====
  nixpkgs.config.allowUnfree = true;

  # ===== LOCALIZATION =====
  time.timeZone = "Europe/Amsterdam";

  # Set locale (if on NixOS)
  i18n = lib.mkIf pkgs.stdenv.isLinux {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # ===== SHELL CONFIGURATION =====
  programs.zsh.enable = true;

  # ===== FONTS (Common across both platforms) =====
  fonts = lib.mkIf pkgs.stdenv.isLinux {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
}
