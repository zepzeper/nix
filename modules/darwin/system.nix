# modules/darwin/system.nix
{ config, lib, pkgs, ... }:

{
  system.primaryUser= "zepzeper";
  # macOS system defaults
  system.defaults = {
    dock.autohide = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.GuestEnabled = false;
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
  };
}
