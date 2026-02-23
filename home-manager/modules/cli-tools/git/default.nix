{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.git;
in {
  options.modules.cliTools.git = {
    enable = lib.mkEnableOption "git tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
    ];

    programs.git = {
      enable = true;

      settings = {
        user = {
          name = "zepzeper";
          email = "wouterschiedam@hotmail.com";
        };
      };
    };
  };
}
