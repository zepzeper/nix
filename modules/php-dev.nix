# modules/php-dev.nix
{ pkgs, lib, ... }:

{
  environment.systemPackages = import ./php-packages.nix { inherit pkgs; };
}
