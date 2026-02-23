{
  config,
  lib,
  ...
}: let
  cfg = config.modules.development;
in {
  imports = [
    ./ai
    ./docker
    ./database
    ./languages
    ./lsp
    ./formatters
    ./search
    ./kubernetes
  ];
}
