# Hosts

One file per machine, registered as `flake.modules.nixos."hosts/<name>"`,
which becomes `nixosConfigurations.<name>`.

- `profiles/` - machine types a host imports (see `profiles/profiles.md`).
- `clients/` - my own machines (desktop).
- `laptops/` - employee laptops.
- `servers/` - ds10u, the Pi.

## Adding a machine

1. Copy the matching template from `templates/` (`host-desktop.nix`,
   `host-laptop.nix`, `host-server.nix`) into the right folder and rename.
2. Fill in every `CHANGE-ME`: the disk (`ls -l /dev/disk/by-id/`) and the
   admin SSH keys.
3. Generate its hardware configuration on the machine as
   `_<name>-hardware.nix` next to the host file and import it.
4. `nix flake check`, then install (see the README).
