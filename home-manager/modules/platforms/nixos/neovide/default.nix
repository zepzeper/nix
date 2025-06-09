{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    neovide
  ];

  programs.neovide = {
    enable = true;
  };

  programs.zsh = {
    shellAliases = {
      nv = "neovide";
    };
  };

}
