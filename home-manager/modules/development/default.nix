{ config, lib, ... }:
let
  cfg = config.modules.development;
in {
  imports = [
    ./languages
    ./lsp
  ];

  options.modules.development = {
    enable = lib.mkEnableOption "development environment";
  };
}
