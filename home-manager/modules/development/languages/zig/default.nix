{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    zig = lib.mkEnableOption "Zig development";
  };

  config = lib.mkIf cfg.zig {
    home.packages = with pkgs; [
      zig
      zls
    ];
  };
}
