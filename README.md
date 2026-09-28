# nix

My NixOS configuration, built with [flake-parts](https://flake.parts) and [import-tree](https://github.com/vic/import-tree).

One repository for three kinds of machine: my desktop, employee laptops, and
servers. They share a base and differ by profile.

## First run

```sh
nix fmt            # format the tree
nix flake check    # formatting, lints, and every host and variant evaluates
```

`flake.lock` pins every input and must stay committed: laptops update
themselves from GitHub and refuse to build without it. Update the pins with
`nix flake update`, check, commit and push.

Then protect `main` on GitHub (Settings -> Branches): require pull requests
and the `check` workflow (`.github/workflows/check.yml`, which runs
`nix flake check`). Laptops install whatever lands on `main`.

## Layout

```
flake.nix                    inputs only
.github/workflows/check.yml  nix flake check on every push and pull request
modules/
  flake-parts/               how the flake itself is wired (no machine config)
  base/                      every machine: nix, users, ssh, locale, hardening
  boot/                      boot loader
  desktops/                  niri + Noctalia (mine), Plasma and GNOME (colleagues)
  disk/                      disko layout: BTRFS, optional LUKS
  hardware/                  firmware, fwupd, zram
  networking/                NetworkManager or systemd-networkd
  services/                  auto-update
  hosts/
    profiles/                base, workstation, laptop, server
    clients/ laptops/ servers/   one file per machine (created with the first host)
templates/                   a block, and a host per machine type (desktop, laptop, server, ARM server)
```

Every `.nix` file under `modules/` is loaded automatically. Files or folders
whose name starts with `_` are skipped, which is where generated hardware
configurations go.

## Machine types

| Profile | For | Adds to base |
| --- | --- | --- |
| `profiles-workstation` | my desktop | NetworkManager, a desktop (niri on mine) |
| `profiles-laptop` | employee laptops | workstation + Plasma (or GNOME per laptop), forced disk encryption with a recovery key, SSH closed to the network, daily auto-update that never reboots on its own. Stable only |
| `profiles-server` | servers, ARM servers | shell only: no desktop, audio or bluetooth; systemd-networkd; unencrypted disk; no automatic updates, deployed by hand. Stable only |

Every profile includes `profiles-base`: SSH for admins only and with keys
only, a locked root, at least one admin with an SSH key (a build error
otherwise), firewall, sudo for wheel only, a sysctl baseline, flakes, weekly
garbage collection.

## Channels

| Channel | nixpkgs | For |
| --- | --- | --- |
| `stable` (default) | nixos-26.05 | employee laptops and servers (enforced by their profiles) |
| `unstable` | nixos-unstable | my own machines |

A host picks its channel next to its module with
`zep.hosts.<name>.channel = "unstable";`. On a stable machine a single newer
package is still available as `pkgs.unstable.<name>`. When a new NixOS
release comes out, bump `nixpkgs` and `home-manager` in `flake.nix`
together.

## Conventions

- **Blocks.** One capability per file, registered as
  `flake.modules.nixos.<name>` (usually `<category>-<name>`), switched with
  `zep.<option>.enable`, settings under `zep.<option>.options.*`. See
  `templates/block.nix`. Home Manager blocks go in
  `flake.modules.homeManager.<name>` and are given to every Home Manager
  user the same way.
- **Profiles.** `profiles-base` imports every block automatically, so its
  option exists everywhere, and forces the mandatory ones on with
  `lib.mkForce`. The other profiles build on it. A host imports one profile.
- **Hosts.** One file per machine, registered as
  `flake.modules.nixos."hosts/<name>"`. It imports its profile and its
  hardware, and sets what is specific to it. See `templates/host-*.nix`.
- **Enforcement.** `lib.mkForce` for what a machine type must have,
  `lib.mkDefault` for suggestions, an assertion for any setting that would
  break a machine or its security.
- **Users.** `zep.users.options.admins` (wheel, SSH keys) and
  `zep.users.options.people` (no admin groups, password set with `passwd` at
  handover). No passwords in this repository. The repository is public: use
  initials or a role rather than an employee's full name.
- **Inputs.** Every input with its own nixpkgs follows ours (the matching
  channel); an input is only added once something uses it.
- **Docs.** Each category folder has a short `<folder>.md`.

See [architecture.md](architecture.md) for the reasoning.

## Installing a machine (desktop, laptop, server)

Boot the NixOS installer ISO in **UEFI mode** (not legacy/CSM) and get it
online (wired, or `nmtui` for WiFi). Then:

```sh
sudo -i
git clone https://github.com/zepzeper/nix && cd nix

# 1. The host file. If it is not in the repository yet, copy the template
#    now (templates/host-desktop.nix, host-laptop.nix, host-server.nix)
#    and fill in every CHANGE-ME. The disk:
ls -l /dev/disk/by-id/

# 2. Hardware configuration, next to the host file; uncomment its import.
nixos-generate-config --no-filesystems --show-hardware-config \
  > modules/hosts/<type>/_<name>-hardware.nix

# 3. Flakes only see files git knows about.
git add -A

# 4. Partition, format and mount - ERASES zep.disk.options.device.
#    Laptops: type the disk passphrase twice, then write down the recovery
#    key disko shows (password manager) before pressing Enter.
nix --extra-experimental-features "nix-command flakes" \
  run --inputs-from . disko -- --mode destroy,format,mount --flake .#<name>

# 5. Install.
nixos-install --flake .#<name> --no-root-passwd --no-channel-copy

# 6. Passwords live on the machine, never in this repository.
nixos-enter --root /mnt -c 'passwd zepzeper'   # admin: needed for sudo
nixos-enter --root /mnt -c 'passwd <person>'   # employee laptops: their account

# 7. Keep this clone: the ISO forgets everything at reboot.
mkdir -p /mnt/home/zepzeper && cp -a /root/nix /mnt/home/zepzeper/nix
nixos-enter --root /mnt -c 'chown -R zepzeper:users /home/zepzeper/nix'
reboot
```

After the first boot, commit and push the host file and its hardware file
from `~/nix` the same day - a laptop's first automatic update looks for them
on GitHub.

## Installing an ARM server

An ARM server boots from an SD card and keeps the partitions of the NixOS SD
image instead of using disko. See `templates/host-server-arm.nix` for the
supported boards.

1. Flash the NixOS 26.05 aarch64 SD image, boot the server on a wired
   network, and log in (user `nixos`, no password).
2. Then:

```sh
sudo -i
git clone https://github.com/zepzeper/nix && cd nix
cp templates/host-server-arm.nix modules/hosts/servers/<name>.nix   # fill in CHANGE-ME, rename "server-arm"
nixos-generate-config --no-filesystems --show-hardware-config \
  > modules/hosts/servers/_<name>-hardware.nix              # uncomment its import
git add -A
nixos-rebuild switch --flake .#<name>
passwd zepzeper
cp -a /root/nix /home/zepzeper/nix && chown -R zepzeper:users /home/zepzeper/nix
reboot
```

Commit and push the two files from `~/nix` afterwards.

## Everyday use

```sh
nix develop                  # nh, nvd, nix-tree

# This machine:
nh os switch .               # build, show the package diff, switch

# Another machine (servers; they never update themselves):
nixos-rebuild switch --flake .#<host> --target-host <host> --ask-sudo-password
nh os build . -H <host>      # only build it, e.g. to check a change
```

Employee laptops pull `main` from GitHub by themselves, so a push to `main`
reaches them within a day. They get exactly what `flake.lock` pins, so
security fixes reach them when the lock is updated and pushed:

```sh
nix flake update && nix flake check && git commit -am "Update inputs" && git push
```
