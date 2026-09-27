# nix

My NixOS configuration, built with [flake-parts](https://flake.parts) and [import-tree](https://github.com/vic/import-tree).

One repository for three kinds of machine: my desktop, employee laptops, and
servers. They share a base and differ by profile.

## First run

```sh
nix flake lock     # create flake.lock
nix fmt            # format the tree
nix flake check    # formatting, lints, and every host and profile evaluates
```

## Layout

```
flake.nix                    inputs only
modules/
  flake-parts/               how the flake itself is wired (no machine config)
  base/                      every machine: nix, users, ssh, locale, hardening
  boot/                      boot loader
  disk/                      disko layout: BTRFS, optional LUKS
  hardware/                  firmware, fwupd, zram
  networking/                NetworkManager or systemd-networkd
  services/                  auto-update
  hosts/
    profiles/                base, workstation, laptop, server
    clients/ laptops/ servers/   one file per machine (none yet)
templates/                   a block, and a host per machine type
```

Every `.nix` file under `modules/` is loaded automatically. Files or folders
whose name starts with `_` are skipped, which is where generated hardware
configurations go.

## Machine types

| Profile | For | Adds to base |
| --- | --- | --- |
| `profiles-workstation` | my desktop | NetworkManager |
| `profiles-laptop` | employee laptops | workstation + forced disk encryption, daily auto-update, never reboots on its own |
| `profiles-server` | servers, the Pi | systemd-networkd, auto-update with reboots between 03:00 and 05:00, no audio or bluetooth |

Every profile includes `profiles-base`: key-only SSH, locked root, at least
one admin with an SSH key (a build error otherwise), firewall, sudo for wheel
only, a sysctl baseline, flakes, weekly garbage collection.

## Conventions

- **Blocks.** One capability per file, registered as
  `flake.modules.nixos.<category>-<name>`, switched with `zep.<name>.enable`,
  settings under `zep.<name>.options.*`. See `templates/block.nix`.
- **Profiles.** `profiles-base` imports every block so its option exists
  everywhere, and forces the mandatory ones on with `lib.mkForce`. The other
  profiles build on it.
- **Hosts.** One file per machine, registered as
  `flake.modules.nixos."hosts/<name>"`. It imports one profile and its
  hardware, and sets what is specific to it. See `templates/host-*.nix`.
- **Enforcement.** `lib.mkForce` for what a machine type must have,
  `lib.mkDefault` for suggestions, an assertion for any setting that would
  break a machine when left empty.
- **Users.** `zep.users.options.admins` (wheel, SSH keys) and
  `zep.users.options.people` (no wheel, password set with `passwd` at
  handover). No passwords in this repository.
- **Inputs.** Every input follows our nixpkgs; an input is only added once
  something uses it.
- **Docs.** Each category folder has a short `<folder>.md`.

See [architecture.md](architecture.md) for the reasoning.

## Installing a machine

From the NixOS installer ISO, after adding its host file:

```sh
sudo -i
nix-shell -p git
git clone https://github.com/zepzeper/nix && cd nix
nixos-generate-config --no-filesystems --show-hardware-config \
  > modules/hosts/<type>/_<name>-hardware.nix   # and import it in the host file

# partition, format and mount - ERASES zep.disk.options.device
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake .#<name>

nixos-install --flake .#<name> --no-root-passwd

# passwords live on the machine, never in this repository
nixos-enter --root /mnt -c 'passwd zepzeper'   # admin: needed for sudo
nixos-enter --root /mnt -c 'passwd anna'       # employee laptops: their account
reboot
```

Then commit the hardware file.

## Everyday use

```sh
nix develop
nh os switch .               # build, show the package diff, switch
nh os switch . -H <host>     # a specific host
nixos-rebuild switch --flake .#<host> --target-host <host> --sudo   # remote
```

Laptops and servers pull `main` from GitHub by themselves, so a push to
`main` reaches them within a day. Protect the branch accordingly.
