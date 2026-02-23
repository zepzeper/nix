{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.recording;
in {
  options.modules.cliTools.recording = {
    enable = lib.mkEnableOption "recording tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wf-recorder
      gpu-screen-recorder
      gpu-screen-recorder-gtk
    ];
  };
}
