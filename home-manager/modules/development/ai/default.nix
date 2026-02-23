{
  config,
  lib,
  ...
}: let
  cfg = config.modules.development.ai;
in {
  imports = [
    ./opencode
  ];
}
