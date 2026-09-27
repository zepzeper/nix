{ lib, config, ... }:
let
  hosts = config.flake.nixosConfigurations;
in
{
  # `nix flake check` evaluates every host, not just some of them. A host that
  # stops evaluating fails the check by name instead of going unnoticed until
  # the next time somebody rebuilds that machine.
  #
  # Only evaluation, no build: the drvPath is forced with its string context
  # dropped, so the check does not depend on (and build) the whole system.
  perSystem =
    { pkgs, system, ... }:
    let
      mine = lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system) hosts;
      evaluated = lib.mapAttrsToList (
        name: host: "${name} ${builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath}"
      ) mine;
    in
    {
      checks.hosts-evaluate = pkgs.writeText "hosts-evaluate" (
        lib.concatLines ([ "hosts evaluated on ${system}:" ] ++ evaluated)
      );
    };
}
