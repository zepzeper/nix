{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.shell.ssh;
in {
  options.modules.shell.ssh = {
    enable = lib.mkEnableOption "ssh configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        github = {
          host = "github.com";
          user = "zepzeper";
          identityFile = "~/.ssh/id_ed25519";
        };

        gitlab = {
          host = "gitlab.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519.chartbuddy";
        };
      };
    };
  };
}
