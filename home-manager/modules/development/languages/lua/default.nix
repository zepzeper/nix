{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages.lua;
in {
  options.modules.development.languages.lua = {
    enable = lib.mkEnableOption "Lua development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      luajit
      luarocks
      lua-language-server
      stylua
    ];
  };
}
