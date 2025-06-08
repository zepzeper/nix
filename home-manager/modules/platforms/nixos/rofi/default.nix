{ config, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    theme = ".config/rofi/rose-pine";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
      disable-history = false;
      sidebar-mode = false;
    };
    plugins = with pkgs; [
      rofi-calc
    ];
  };
}
