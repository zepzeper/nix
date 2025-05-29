{ config, lib, pkgs, username, ... }:

{
  # Homebrew configuration
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # Removes all unmanaged formulae
    };
    taps = [
      "nikitabobko/tap"
    ];
    # Install AeroSpace as a cask
    casks = [
      "aerospace"
    ];
  };

  # nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    autoMigrate = true;
  };
}
