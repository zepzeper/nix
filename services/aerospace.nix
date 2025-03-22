{ config, pkgs, ... }:

{
  # Create a launchd service for AeroSpace
  launchd.user.agents.aerospace = {
    serviceConfig = {
      Label = "com.nikitabobko.aerospace";
      ProgramArguments = [
        "/Applications/AeroSpace.app/Contents/MacOS/AeroSpace"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/aerospace.log";
      StandardErrorPath = "/tmp/aerospace.error.log";
    };
  };
}
