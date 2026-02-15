{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages.zig;
in {
  options.modules.development.languages.zig = {
    enable = lib.mkEnableOption "Zig development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zig
      zls
    ];
  };
}
