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
block      one capability       zep.<name>.enable + zep.<name>.options.*
profile    a machine type       base -> workstation -> laptop
                                base -> server
host       one machine          one profile + hardware + its own settings
```

`profiles-base` imports every block, so a host can switch any block on
without importing it itself. Importing a block never enables it.

## Decisions

### Blocks are switched, not imported
A host file reads like a settings page: which profile, which hardware, what
is specific to it. The alternative, importing a module to enable it, spreads
the list of what a machine has across import lists.

### mkForce for mandatory, mkDefault for suggested
What a machine type must have is forced in its profile, so a host cannot lose
it by accident: SSH hardening, the firewall and a locked root on every
machine; disk encryption on every laptop. Everything else is a default a host
can override. A setting that would break a machine when empty (no admin, no
disk) asserts at build time.

### Machine types are profiles, layered
Employee laptops are workstations with stricter rules, so `profiles-laptop`
imports `profiles-workstation` and adds to it. Servers share only the base.
One place per rule: encryption is decided in the laptop profile, not on each
laptop.

### No passwords in the repository
Admins log in with SSH keys. People (employees) get an account without a
password, and the password is set on the machine at handover. Users are
mutable, so it survives rebuilds.

### Machines update themselves from main
Laptops and servers pull this flake on a schedule and switch
(`system.autoUpgrade`). Nobody has to reach a laptop to update it. The
cost is that `main` is trusted by every machine, so it must be protected.

### Home Manager as a NixOS module
The system and the user environment build, switch and roll back together.

### Every host and every profile is evaluated by `nix flake check`
Each profile is evaluated on a stand-in machine, so the base is checked
before any real machine exists, and a host that stops evaluating fails the
check by name.
