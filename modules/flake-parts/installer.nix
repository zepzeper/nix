{ inputs, lib, ... }:
let
  # Who may log in to the installer: my SSH keys (the same file that makes
  # me an admin on every machine).
  sshKeys = lib.filter (line: line != "" && !lib.hasPrefix "#" line) (
    lib.splitString "\n" (builtins.readFile ../users/zepzeper/authorized_keys)
  );

  # The NixOS minimal installer (stable), plus what installing from this
  # repository needs, so a machine booted from it can be installed at the
  # machine or from my desktop over SSH straight away:
  # - SSH on, accepting my keys, as root (what nixos-anywhere logs in as) and
  #   as nixos;
  # - flakes and git.
  installer =
    system:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        (
          { pkgs, ... }:
          {
            nixpkgs.hostPlatform = system;
            networking.hostName = "installer";
            image.baseName = lib.mkForce "zep-installer-${system}";
            # The installer can read ZFS; no pool is ever imported at boot.
            boot.zfs.forceImportRoot = false;

            services.openssh.enable = true;
            users.users = {
              root.openssh.authorizedKeys.keys = sshKeys;
              nixos.openssh.authorizedKeys.keys = sshKeys;
            };

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
            environment.systemPackages = [ pkgs.git ];
          }
        )
      ];
    };
in
{
  # nix build .#installer-iso    -> result/iso/zep-installer-x86_64-linux.iso
  flake.nixosConfigurations.installer = installer "x86_64-linux";

  perSystem =
    { system, ... }:
    lib.optionalAttrs (system == "x86_64-linux") {
      packages.installer-iso = (installer system).config.system.build.isoImage;
    };
}
