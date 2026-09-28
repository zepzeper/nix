# Architecture

## How the flake is assembled

1. `flake.nix` declares inputs and hands `./modules` to import-tree.
2. import-tree loads every `.nix` file under `modules/` as a flake-parts
   module (skipping paths that contain `/_`).
3. Each file registers what it provides under `flake.modules.nixos.<name>`
   (and `flake.modules.homeManager.<name>` for the user side). Every block
   carries a `key`, so importing it twice is harmless.
4. `modules/flake-parts/host-machines.nix` turns every
   `flake.modules.nixos."hosts/<name>"` into `nixosConfigurations.<name>`,
   with Home Manager wired in.

## Blocks, profiles, hosts

```
block      one capability       zep.<option>.enable + zep.<option>.options.*
profile    a machine type       base -> workstation -> laptop
                                base -> server
host       one machine          one profile + hardware + its own settings
```

`profiles-base` imports every block (found automatically: everything in
`flake.modules.nixos` that is not a profile or a host), so a host can switch
any block on without importing it itself. Importing a block never enables it.
Home Manager blocks are handed to every Home Manager user the same way.

## Decisions

### Blocks are switched, not imported
A host file reads like a settings page: which profile, which hardware, what
is specific to it. The alternative, importing a module to enable it, spreads
the list of what a machine has across import lists.

### mkForce for mandatory, mkDefault for suggested
What a machine type must have is forced in its profile, so a host cannot lose
it by accident: SSH policy and the firewall on every machine; disk encryption
on every workstation and laptop. Everything else is a default a host can override. A setting
that would break a machine or its security asserts at build time: no admin,
no disk, an employee in an admin group, an encrypted server nobody can
unlock, a laptop or server on unstable, auto-update without a lock file.

### Machine types are profiles, layered
Employee laptops are workstations with stricter rules, so `profiles-laptop`
imports `profiles-workstation` and adds to it. Servers share only the base.
One place per rule: encryption is decided in the workstation profile, not on
each machine.

### No passwords in the repository
Admins log in with SSH keys. People (employees) get an account without a
password, and the password is set on the machine at handover. Users are
mutable, so it survives rebuilds. The same means root's "!" is its initial
state: it stays locked unless an admin deliberately sets a root password.

### SSH: policy forced, crypto left to nixpkgs
Only wheel may log in, only with keys from this repository (never from
`~/.ssh`), never as root. The ciphers and key exchange are nixpkgs' own
defaults, which are hardened already and gain new algorithms (post-quantum
key exchange) with each release; a forced list here froze them once and
dropped one. Laptops do not accept SSH from the network at all.

### Trusted Nix users only where deploys land
A trusted Nix user can import unsigned store paths, which is root without a
password. Servers need it for `nixos-rebuild --target-host`, so only the
server profile makes wheel trusted.

### Stable for machines others depend on, unstable for mine
Two nixpkgs inputs, each with its matching Home Manager branch. A host picks
one with `zep.hosts.<name>.channel` (default stable). The choice lives at the
flake level because it decides which nixpkgs evaluates the host at all. The
laptop and server profiles assert stable, so an employee laptop or a server
cannot end up on unstable by accident. `pkgs.unstable` covers the odd package
a stable machine needs newer.

### Laptops update themselves; servers are deployed by hand
Employee laptops pull this flake on a schedule and switch
(`system.autoUpgrade`), so nobody has to reach a laptop; the cost is that
`main` is trusted by every laptop and must be protected. Servers never change
on their own: an admin deploys with `nixos-rebuild --target-host`. In both
cases `flake.lock` decides what "latest" means.

### Home Manager as a NixOS module
The system and the user environment build, switch and roll back together.

### Every host and every profile is evaluated by `nix flake check`
Each profile is evaluated on a stand-in machine, so the base is checked
before any real machine exists, and a host that stops evaluating fails the
check by name.
