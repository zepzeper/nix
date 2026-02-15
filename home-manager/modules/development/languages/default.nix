{
  config,
  lib,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  imports = [
    ./c
    ./zig
    ./go
    ./haskell
    ./rust
    ./typescript
    ./lua
    ./php
    ./nix
  ];

  options.modules.development.languages = {
    enable = lib.mkEnableOption "programming languages";
  };
}
