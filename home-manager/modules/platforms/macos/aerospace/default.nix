{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    aerospace
  ];

	settings = builtins.fromTOML (builtins.readFile "${config.home.homeDirectory}/.dotfiles/aerospace/aerospace.toml");

}
