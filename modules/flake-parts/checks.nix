{ lib, config, ... }:
let
  inherit (config.flake) nixosConfigurations;
  inherit (config.flake.modules) nixos;

  # A stand-in machine per profile (and per desktop, on the channel that
  # profile runs), so the base is checked before any real machine exists:
  # every combination has to produce a system that evaluates, assertions
  # included.
  variants = {
    workstation-niri = {
      channel = "unstable";
      profile = "workstation";
      settings = {
        zep.desktop.options.environment = "niri";
        # A Home Manager user, so the niri/Noctalia user config is checked too.
        home-manager.users.check.home.stateVersion = "26.05";
      };
    };
    laptop-plasma = {
      channel = "stable";
      profile = "laptop";
      settings = { };
    };
    laptop-gnome = {
      channel = "stable";
      profile = "laptop";
      settings.zep.desktop.options.environment = "gnome";
    };
    server = {
      channel = "stable";
      profile = "server";
      settings = { };
    };
    server-hetzner = {
      channel = "stable";
      profile = "server";
      settings.zep = {
        hetznerCloud = {
          enable = true;
          options.ipv6 = "2a01:4f8:c012:3456::1/64";
        };
        tailscale.enable = true;
      };
    };
  };

  stubs =
    system:
    lib.mapAttrs (
      name: variant:
      config.flake.lib.mkHost "check-${name}" variant.channel {
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

  # zep.hosts.<name> for a name with no host module is a typo.
  hostNames = lib.attrNames nixosConfigurations;
  unknown = lib.subtractLists hostNames (lib.attrNames config.zep.hosts);

  # Forces the whole system (assertions included) without building it: the
  # drvPath is taken with its string context dropped. Warnings fail too - a
  # warning today is usually an error in the next release.
  evaluate =
    name: host:
    let
      inherit (host.config) warnings;
    in
    lib.throwIf (warnings != [ ]) "${name}: ${lib.concatStringsSep "\n" warnings}"
      "${name} ${builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath}";
in
{
  # `nix flake check` evaluates every host - of every architecture, from
  # whatever machine runs it - and every stand-in variant. A machine that
  # stops evaluating, or starts warning, fails the check by name.
  perSystem =
    { pkgs, system, ... }:
    {
      # Builds the checked config files the niri desktop installs: this runs
      # `niri validate` and `noctalia config validate` on them, so a mistake
      # in either fails CI rather than a login.
      checks.desktop-configs =
        let
          files = (stubs system).workstation-niri.config.home-manager.users.check.xdg.configFile;
        in
        pkgs.linkFarm "desktop-configs" [
          {
            name = "niri-config.kdl";
            path = files."niri/config.kdl".source;
          }
          {
            name = "noctalia-config.toml";
            path = files."noctalia/config.toml".source;
          }
        ];

      checks.hosts-evaluate = pkgs.writeText "hosts-evaluate" (
        lib.throwIf (unknown != [ ])
          "zep.hosts is set for ${lib.concatStringsSep ", " unknown}, but there is no host by that name (typo?)"
          (
            lib.concatLines (
              [ "evaluated from ${system}:" ]
              ++ lib.mapAttrsToList evaluate nixosConfigurations
              ++ lib.mapAttrsToList (name: evaluate "variant ${name}") (stubs system)
            )
          )
      );
    };
}
