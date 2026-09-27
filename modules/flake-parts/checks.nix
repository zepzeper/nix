{ lib, config, ... }:
let
  inherit (config.flake) nixosConfigurations;
  inherit (config.flake.modules) nixos;

  # A stand-in machine per profile (and per desktop), so the base is checked
  # before any real machine exists: every combination has to produce a
  # system that evaluates, assertions included.
  variants = {
    workstation-niri = {
      profile = "workstation";
      settings.zep.desktop.options.environment = "niri";
    };
    laptop-plasma = {
      profile = "laptop";
      settings = { };
    };
    laptop-gnome = {
      profile = "laptop";
      settings.zep.desktop.options.environment = "gnome";
    };
    server = {
      profile = "server";
      settings = { };
    };
  };

  stubs =
    system:
    lib.mapAttrs (
      name: variant:
      config.flake.lib.mkHost "check-${name}" {
        imports = [
          nixos."profiles-${variant.profile}"
          variant.settings
        ];
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
    ) variants;
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
