{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools;
in {
  options.modules.cliTools = {
    recording = lib.mkEnableOption "recording tools";
  };

  config = lib.mkIf cfg.recording {
    home.packages = with pkgs; [
      wf-recorder
      gpu-screen-recorder
      gpu-screen-recorder-gtk
    ];
  };
}
