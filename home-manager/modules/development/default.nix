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
    ./formatters
    ./search
    ./kubernetes
  ];
}
