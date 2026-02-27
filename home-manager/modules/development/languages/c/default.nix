{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    c = lib.mkEnableOption "C/C++ development";
  };

  config = lib.mkIf cfg.c {
    home.packages = with pkgs; [
      gcc
      clang-tools # clangd LSP
      cmake
      gnumake
      pkg-config
      gdb
    ];
  };
}
