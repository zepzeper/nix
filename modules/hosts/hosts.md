# Hosts

One file per machine, registered as `flake.modules.nixos."hosts/<name>"`,
which becomes `nixosConfigurations.<name>`.

- `profiles/` - machine types a host imports (see `profiles/profiles.md`).
- `clients/` - my own machines (desktop).
- `laptops/` - employee laptops.
- `servers/` - servers, including ARM servers.

## Adding a machine

1. Copy the matching template from `templates/` (`host-desktop.nix`,
   `host-laptop.nix`, `host-server.nix`, `host-server-hetzner.nix`,
   `host-server-arm.nix`) into the
   right folder and rename.
2. Fill in every `CHANGE-ME` (the disk: `ls -l /dev/disk/by-id/`). I am
   the admin through `users/zepzeper`, which the templates import; my SSH
   keys are in `modules/users/zepzeper/authorized_keys` (one line per
   machine I work from).
3. Pick its channel: stable is the default; for one of my own machines add
   `zep.hosts.<name>.channel = "unstable";` next to the host module.
4. Generate its hardware configuration on the machine as
   `_<name>-hardware.nix` next to the host file and import it.
5. `nix flake check`, then install (see the README; servers can be
   installed from the desktop with nixos-anywhere).
6. After the install, give it its secrets: its host key in
   `secrets/hosts/<name>.pub` (see `secrets/README.md`).
