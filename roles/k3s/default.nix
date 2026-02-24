{
  config,
  lib,
  ...
}: let
  cfg = config.k3s;
in {
  imports = [
    ./k3s-master.nix
    ./k3s-worker.nix
  ];
}
