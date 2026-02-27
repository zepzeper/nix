{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.cliTools.terminal;
in {
  options.modules.cliTools.terminal = {
    fzf = lib.mkEnableOption "fzf fuzzy finder";
  };

  config = lib.mkIf cfg.fzf {
    home.packages = with pkgs; [
      fzf
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
