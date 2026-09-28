{
  # Who can log in. Two kinds of account:
  #
  #   admins  - you (and whoever helps you). In wheel, log in with SSH keys.
  #             sudo asks for their password, which is set on the machine at
  #             install (`nixos-enter --root /mnt -c 'passwd <name>'`).
  #   people  - the person using the machine, e.g. an employee on a laptop.
  #             Not in wheel. Created without a password: set one with
  #             `passwd <name>` when you hand the machine over. Because users
  #             are mutable, that password survives rebuilds and never ends up
  #             in this (public) repository.
  #
  # root starts locked and stays locked unless an admin deliberately gives it
  # a password (with mutable users, the "!" below is the initial state, not
  # something re-applied on every switch). Without at least one admin nobody
  # could administer the machine, so that is a build error rather than a
  # surprise after install.
  #
  # people cannot be put in groups that are root in disguise (wheel, docker,
  # ...), and a name can be an admin or a person, not both.
  flake.modules.nixos.base-users =
    { config, lib, ... }:
    let
      cfg = config.zep.users;

      # Membership in any of these is as good as root.
      adminGroups = [
        "wheel"
        "docker"
        "podman"
        "libvirtd"
        "lxd"
        "incus-admin"
        "disk"
      ];

      admin = lib.types.submodule {
        options = {
          description = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          sshKeys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Public SSH keys that may log in as this admin.";
          };
        };
      };

      person = lib.types.submodule {
        options = {
          description = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
      };
    in
    {
      key = "zep#base-users";
      options.zep.users = {
        enable = lib.mkEnableOption "admin and personal user accounts";

        options.admins = lib.mkOption {
          type = lib.types.attrsOf admin;
          default = { };
          example = {
            zepzeper.sshKeys = [ "ssh-ed25519 AAAA... zepzeper@desktop" ];
          };
          description = "Administrators: in wheel, log in over SSH with a key.";
        };

        options.people = lib.mkOption {
          type = lib.types.attrsOf person;
          default = { };
          example = {
            anna.description = "Anna de Vries";
          };
          description = "People who use the machine but do not administer it.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.options.admins != { };
            message = "zep.users.options.admins is empty: root is locked, so nobody could administer this machine.";
          }
          {
            assertion = lib.all (a: a.sshKeys != [ ]) (lib.attrValues cfg.options.admins);
            message = "Every admin in zep.users.options.admins needs at least one SSH key.";
          }
          {
            assertion = lib.all (p: lib.intersectLists p.extraGroups adminGroups == [ ]) (
              lib.attrValues cfg.options.people
            );
            message = "zep.users.options.people: ${lib.concatStringsSep ", " adminGroups} make a user root-equivalent. Make them an admin instead.";
          }
          {
            assertion =
              lib.intersectLists (lib.attrNames cfg.options.admins) (lib.attrNames cfg.options.people) == [ ]
              && !(cfg.options.admins ? root || cfg.options.people ? root);
            message = "zep.users: a name is listed as both admin and person, or as root.";
          }
        ];

        users = {
          mutableUsers = lib.mkDefault true;

          users = {
            root.hashedPassword = "!";
          }
          // lib.mapAttrs (_: a: {
            isNormalUser = true;
            inherit (a) description;
            extraGroups = [ "wheel" ];
            openssh.authorizedKeys.keys = a.sshKeys;
          }) cfg.options.admins
          // lib.mapAttrs (_: p: {
            isNormalUser = true;
            inherit (p) description extraGroups;
          }) cfg.options.people;
        };

        # Admins authenticate with keys; sudo still asks for their password.
        security.sudo.wheelNeedsPassword = lib.mkDefault true;
      };
    };
}
