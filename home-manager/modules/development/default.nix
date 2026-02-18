{
  config,
  lib,
  ...
}: let
  cfg = config.modules.development;
in {
  imports = [
    ./docker
    ./database
    ./languages
    ./lsp
  ];

  options.modules.development = {
    enable = lib.mkEnableOption "development environment";
  };
}
