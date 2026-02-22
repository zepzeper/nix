{
  inputs,
  outputs,
  stateVersion,
  lib,
  ...
}: let
  helpers = import ./helpers.nix {inherit inputs outputs stateVersion lib;};
in {
  inherit
    (helpers)
    mkHome
    mkWorkstation
    mkServer
    mkMinimal
    forAllSystems
    ;
}
