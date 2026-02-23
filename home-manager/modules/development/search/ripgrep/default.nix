{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.search.ripgrep;
in {
  options.modules.development.search.ripgrep = {
    enable = lib.mkEnableOption "ripgrep search tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
    ];
  };
}
