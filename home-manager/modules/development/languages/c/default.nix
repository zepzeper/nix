{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages.c;
in {
  options.modules.development.languages.c = {
    enable = lib.mkEnableOption "C/C++ development";
  };

  config = lib.mkIf cfg.enable {
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
