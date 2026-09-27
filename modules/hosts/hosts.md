# Hosts

One file per machine, registered as `flake.modules.nixos."hosts/<name>"`,
which becomes `nixosConfigurations.<name>`.

- `profiles/` - sets of blocks a host imports. `base.nix` is imported by
  every machine.
- `clients/` - desktop, laptop (to be added).
- `servers/` - ds10u, pi (to be added).

## Adding a machine

1. Copy `templates/host.nix` to `modules/hosts/<clients|servers>/<name>.nix`
   and replace `example` with the machine's name.
2. Put its generated hardware configuration next to it as
   `_<name>-hardware.nix` and import it from the host file.
3. Set `nixpkgs.hostPlatform` and `system.stateVersion`.
4. `nix flake check`, then `nh os switch . -H <name>`.
