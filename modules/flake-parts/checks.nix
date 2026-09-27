{ lib, config, ... }:
let
  inherit (config.flake) nixosConfigurations;
  inherit (config.flake.modules) nixos;

  # A stand-in machine per profile, so the base is checked before any real
  # machine exists: every profile has to produce a system that evaluates,
  # assertions included.
  stubs =
    system:
    lib.genAttrs [ "workstation" "laptop" "server" ] (
      profile:
      config.flake.lib.mkHost "check-${profile}" {
        imports = [ nixos."profiles-${profile}" ];
        nixpkgs.hostPlatform = system;
        system.stateVersion = "26.05";
        zep = {
          disk.options.device = "/dev/disk/by-id/check";
          users.options = {
            admins.check.sshKeys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA check"
            ];
            people.person = { };
          };
        };
      }
    );
in
{
  # `nix flake check` evaluates every host and every profile, not just some
  # of them. A machine that stops evaluating fails the check by name instead
  # of going unnoticed until the next rebuild.
  #
  # Only evaluation, no build: the drvPath is forced with its string context
  # dropped, so the check does not depend on (and build) the whole system.
  perSystem =
    { pkgs, system, ... }:
    let
      hosts = lib.filterAttrs (
        _: host: host.pkgs.stdenv.hostPlatform.system == system
      ) nixosConfigurations;

      line =
        name: host:
        "${name} ${builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath}";
    in
    {
      checks.hosts-evaluate = pkgs.writeText "hosts-evaluate" (
        lib.concatLines (
          [ "evaluated on ${system}:" ]
          ++ lib.mapAttrsToList line hosts
          ++ lib.mapAttrsToList (profile: line "profile ${profile}") (stubs system)
        )
      );
    };
}
