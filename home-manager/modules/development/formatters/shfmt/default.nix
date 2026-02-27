{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.formatters;
in {
  options.modules.development.formatters = {
    shfmt = lib.mkEnableOption "shfmt shell formatter";
  };

  config = lib.mkIf cfg.shfmt {
    home.packages = with pkgs; [
      shfmt
    ];
  };
}
