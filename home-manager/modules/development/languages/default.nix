{
  config,
  lib,
  pkgs,
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
}
