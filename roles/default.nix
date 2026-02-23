{
  config,
  pkgs,
  lib,
  username,
  inputs,
  ...
}: {
  imports = [
    ./minimal
    ./workstation
    ./server
    ./k3s
  ];
}
