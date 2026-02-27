{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools;
in {
  options.modules.cliTools = {
    git = lib.mkEnableOption "git tools";
  };

  config = lib.mkIf cfg.git {
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
