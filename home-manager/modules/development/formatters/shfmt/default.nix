{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.formatters.shfmt;
in {
  options.modules.development.formatters.shfmt = {
    enable = lib.mkEnableOption "shfmt shell formatter";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      shfmt
    ];
  };
}
