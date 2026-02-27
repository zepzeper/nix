{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.search;
in {
  options.modules.development.search = {
    ripgrep = lib.mkEnableOption "ripgrep search tool";
  };

  config = lib.mkIf cfg.ripgrep {
    home.packages = with pkgs; [
      ripgrep
    ];
  };
}
