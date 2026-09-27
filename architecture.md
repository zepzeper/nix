# Architecture

## How the flake is assembled

1. `flake.nix` declares inputs and hands `./modules` to import-tree.
2. import-tree loads every `.nix` file under `modules/` as a flake-parts
   module (skipping paths that contain `/_`).
3. Each file registers what it provides under `flake.modules.nixos.<name>`
   (and `flake.modules.homeManager.<name>` for the user side).
4. `modules/flake-parts/host-machines.nix` turns every
   `flake.modules.nixos."hosts/<name>"` into `nixosConfigurations.<name>`,
   with Home Manager wired in.

## Blocks, profiles, hosts

```
block      one capability           zep.<name>.enable + zep.<name>.options.*
profile    a set of blocks          profiles-base (every machine), later
                                    profiles-workstation, profiles-server
host       one machine              imports profiles + hardware, enables blocks
```

The base profile imports every block, so a host can switch any block on
without importing it itself. Importing a block never enables it.

## Decisions

### Blocks are switched, not imported
A host file reads like a settings page: which profile, which hardware, which
blocks are on. The alternative, importing a module to enable it, keeps option
declarations out of hosts that do not use them but spreads the list of what a
machine has across import lists.

### mkForce for mandatory, mkDefault for suggested
The few things every machine must have are forced in the base profile, so a
host cannot lose them by accident. Everything else is a default a host can
override. A setting that would break a machine when empty asserts at build
time.

### Home Manager as a NixOS module
The system and the user environment build, switch and roll back together. No
separate `home-manager switch`, no `--impure`.

### Every host is evaluated by `nix flake check`
A host that stops evaluating fails the check by name, rather than surfacing
the next time that machine is rebuilt.
