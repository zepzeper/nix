{ config, pkgs, ... }:
{

  home.packages = with pkgs; [
    love
  ];
}
