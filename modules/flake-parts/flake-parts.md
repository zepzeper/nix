# Flake parts

How the flake itself is put together. Nothing here configures a machine.

| File | Purpose |
| --- | --- |
| `flake-parts.nix` | Enables `flake.modules` and declares the systems. |
| `host-machines.nix` | Turns `hosts/<name>` modules into `nixosConfigurations`, on the channel set in `zep.hosts.<name>.channel`. |
| `treefmt.nix` | `nix fmt` and the formatting check (nixfmt, statix, deadnix). |
| `checks.nix` | `nix flake check` evaluates every host (all architectures) and a stand-in per machine type, fails on warnings and on a `zep.hosts` typo; checks each secret is encrypted to the machines `agenix-rules.nix` names; builds the niri and Noctalia config files, which runs their validators. |
| `devshell.nix` | `nix develop` with nvd, nix-tree and nixos-anywhere (nh is on every machine). |
| `installer.nix` | The installer ISO. |
| `project-templates.nix` | `nix flake init -t .#<language>` project templates. |
