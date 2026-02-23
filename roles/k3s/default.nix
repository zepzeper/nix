{
  config,
  lib,
  ...
}:

let
  cfg = config.k3s;
in {
  imports = [
    ./manifests
    ./k3s-master.nix
    ./k3s-worker.nix
  ];
}
