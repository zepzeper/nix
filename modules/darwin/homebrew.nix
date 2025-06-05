{ inputs, pkgs, lib, ... }:

{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  config = {
    nix-homebrew = {
      enable = true;
      user = "zepzeper";
      autoMigrate = true;
      enableRosetta = true;
    };
  };
}

