# nix

My NixOS configuration, built with [flake-parts](https://flake.parts) and [import-tree](https://github.com/vic/import-tree).

## First run

```sh
nix flake lock     # create flake.lock
nix fmt            # format the tree
nix flake check    # formatting, lints, and every host evaluates
```

## Layout

```
flake.nix                    inputs only
modules/
  flake-parts/               how the flake itself is wired
    flake-parts.nix          flake.modules option + systems
    host-machines.nix        hosts/<name> -> nixosConfigurations.<name>
    treefmt.nix              nix fmt: nixfmt, statix, deadnix
    checks.nix               every host must evaluate
    devshell.nix             nix develop: nh, nvd, nix-tree
  hosts/
    profiles/base.nix        imported by every machine
templates/
  block.nix                  copy to start a new block
  host.nix                   copy to start a new machine
```

Every `.nix` file under `modules/` is loaded automatically. Files or folders
whose name starts with `_` are skipped, which is where generated hardware
configurations go.

## Conventions

- **Blocks.** One capability per file, registered as
  `flake.modules.nixos.<category>-<name>`, switched with `zep.<name>.enable`,
  settings under `zep.<name>.options.*`. See `templates/block.nix`.
- **Profiles.** `profiles-base` imports every block so its option exists
  everywhere, and forces the mandatory ones on with `lib.mkForce`. Role
  profiles (workstation, server) can be added next to it and enable a set of
  blocks with `lib.mkDefault`.
- **Hosts.** One file per machine, registered as
  `flake.modules.nixos."hosts/<name>"`. It imports profiles and its hardware,
  and turns on what it needs. See `templates/host.nix`.
- **Enforcement.** `lib.mkForce` for what every machine must have,
  `lib.mkDefault` for suggestions, an assertion for any setting that would
  break a machine when left empty.
- **Inputs.** Every input follows our nixpkgs; an input is only added once
  something uses it.
- **Docs.** Each category folder gets a short `<folder>.md` saying what it is
  for.

See [architecture.md](architecture.md) for the reasoning.

## Everyday use

```sh
nix develop
nh os switch .               # build, show the package diff, switch
nh os switch . -H <host>     # a specific host
nixos-rebuild switch --flake .#<host> --target-host <host> --sudo   # remote
```
