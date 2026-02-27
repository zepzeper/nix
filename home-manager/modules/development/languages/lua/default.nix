{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    lua = lib.mkEnableOption "Lua development";
  };

  config = lib.mkIf cfg.lua {
    home.packages = with pkgs; [
      luajit
      luarocks
      lua-language-server
      stylua
    ];
  };
}
