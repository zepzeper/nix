{ lib, pkgs, username, ... }:

let
  linuxLocale = lib.optionalAttrs pkgs.stdenv.isLinux {
    i18n = {
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
  };
in
{
  imports = [ ./users.nix ];

  config = {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" username ];
    };

    nixpkgs.config.allowUnfree = true;
    time.timeZone = "Europe/Amsterdam";

    programs.zsh.enable = true;

    fonts = lib.mkIf pkgs.stdenv.isLinux {
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
    };
  } // linuxLocale;
}

