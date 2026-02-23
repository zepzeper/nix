{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal.fzf;
in {
  options.modules.cliTools.terminal.fzf = {
    enable = lib.mkEnableOption "fzf fuzzy finder";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
