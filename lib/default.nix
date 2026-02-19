{
  inputs,
  outputs,
  stateVersion,
  ...
}: let
  helpers = import ./helpers.nix {inherit inputs outputs stateVersion;};
in {
  inherit
    (helpers)
    mkHome
    mkWorkstation
    mkServer
    mkMinimal
    mkNixOS  # Legacy alias
    forAllSystems
    ;
}
