{ config, pkgs, ... }:
{

  home.packages = with pkgs; [
    redis
  ];

  programs.zsh = {
    shellAliases = {
    };
  };
}
