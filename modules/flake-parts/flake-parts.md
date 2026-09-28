# Flake parts

How the flake itself is put together. Nothing here configures a machine.

| File | Purpose |
| --- | --- |
| `flake-parts.nix` | Enables `flake.modules` and declares the systems. |
| `host-machines.nix` | Turns `hosts/<name>` modules into `nixosConfigurations`, on the channel set in `zep.hosts.<name>.channel`. |
| `treefmt.nix` | `nix fmt` and the formatting check (nixfmt, statix, deadnix). |
| `checks.nix` | `nix flake check` evaluates every host (all architectures) and a stand-in per machine type, fails on warnings and on a `zep.hosts` typo. |
| `devshell.nix` | `nix develop` with nh, nvd and nix-tree. |
