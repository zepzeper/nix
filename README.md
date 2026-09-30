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
themselves from GitHub and refuse to build without it. Every Monday the
`update-inputs` workflow updates it and opens a pull request (setup: the
comment at the top of `.github/workflows/update-inputs.yml`).

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
  apps/                      programs people use: Helium, Spotify (Spicetify), Steam, LocalSend
  boot/                      boot loader
  desktops/                  niri + Noctalia (mine), Plasma and GNOME (colleagues)
  development/               languages, Docker, VMs, tools; Neovim (its config is the zepzeper/nvim repo)
  disk/                      disko layout: BTRFS, optional LUKS
  hardware/                  firmware, fwupd, graphics, zram
  networking/                NetworkManager or systemd-networkd
  secrets/                   agenix (the secrets themselves are in secrets/ at the root)
  services/                  auto-update, Tailscale, printing, Kodai (test server)
  shell/                     zsh and tmux (with tmux-sessionizer), on every machine
  users/                     a person: their dotfiles, Home Manager settings and secrets on a machine
  hosts/
    profiles/                base, workstation, laptop, server
    clients/ laptops/ servers/   one file per machine
secrets/                     encrypted secrets (agenix), see secrets/README.md
templates/                   a block, a host per machine type (desktop, laptop, server, Hetzner Cloud server, ARM server),
                             and projects/: development shells for new projects (nix flake init -t .#go)
```

Every `.nix` file under `modules/` is loaded automatically. Files or folders
whose name starts with `_` are skipped, which is where generated hardware
configurations go.

## Machine types

| Profile | For | Adds to base |
| --- | --- | --- |
| `profiles-workstation` | my desktop | NetworkManager, a desktop (niri on mine), graphics drivers, forced disk encryption with a recovery key |
| `profiles-laptop` | employee laptops | workstation + Plasma (or GNOME per laptop), SSH closed to the network, daily auto-update that never reboots on its own. Stable only |
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

## Installing a machine

### The installer

Any NixOS minimal ISO works; my own is quicker, because it starts SSH with
my keys (`modules/users/zepzeper/authorized_keys`) and has flakes and git:

```sh
nix build .#installer-iso      # result/iso/zep-installer-x86_64-linux.iso
sudo dd if=result/iso/zep-installer-x86_64-linux.iso of=/dev/sdX bs=4M conv=fsync oflag=direct status=progress
```

Boot it in **UEFI mode** (not legacy/CSM, Secure Boot off; on a desktop
or laptop also clear the Secure Boot keys, "Setup Mode", so the installed
system can enroll its own) and get it online
(wired, or `nmtui` for WiFi). `ip -brief address` shows its address; from
the desktop `ssh root@<address>` then gets you in.

### The host file

Copy the template (`templates/host-desktop.nix`, `host-laptop.nix` or
`host-server.nix`) to `modules/hosts/<clients|laptops|servers>/<name>.nix`,
rename it, fill in every CHANGE-ME, and uncomment the hardware import. The
disk, as seen on the machine: `ls -l /dev/disk/by-id/` (the whole disk, not
a `-part`; the NVMe or SSD it should run from). Push it only once the
machine is installed: until its hardware file exists it does not build.
(The Hetzner template imports its hardware file only once it exists, so a
Hetzner host can be pushed before.)

### Desktops and laptops (encrypted): at the machine

Also over SSH from the desktop into the installer; disko needs someone to
type the disk passphrase either way.

```sh
sudo -i
git clone https://github.com/zepzeper/nix && cd nix      # plus the new host file

# 1. Hardware configuration, next to the host file.
nixos-generate-config --no-filesystems --show-hardware-config \
  > modules/hosts/<type>/_<name>-hardware.nix

# 2. Flakes only see files git knows about.
git add -A

# 3. Partition, format and mount - ERASES zep.disk.options.device.
#    Type the disk passphrase twice, then write down the recovery key disko
#    shows (password manager) before pressing Enter.
nix --extra-experimental-features "nix-command flakes" \
  run --inputs-from . disko -- --mode destroy,format,mount --flake .#<name>

# 4. Install.
nixos-install --flake .#<name> --no-root-passwd --no-channel-copy

# 5. Passwords live on the machine, never in this repository.
nixos-enter --root /mnt -c 'passwd zepzeper'   # admin: needed for sudo
nixos-enter --root /mnt -c 'passwd <person>'   # employee laptops: their account

# 6. Keep this clone: the installer forgets everything at reboot.
mkdir -p /mnt/home/zepzeper/personal && cp -a /root/nix /mnt/home/zepzeper/personal/nix
nixos-enter --root /mnt -c 'chown -R zepzeper:users /home/zepzeper/personal'
reboot
```

Commit and push the host file and its hardware file the same day: a
laptop's first automatic update looks for them on GitHub. A laptop has no
GitHub access of its own, so fetch the hardware file to the desktop before
the reboot (installer booted from my ISO, so SSH is on) and commit there:

```sh
scp root@<installer-address>:/root/nix/modules/hosts/laptops/_<name>-hardware.nix modules/hosts/laptops/
git add -A && git commit -m "Add <name>" && git push
```

### Handing over a laptop

With the colleague there, after its first boot (the disk still wants the
install passphrase this once). Its first boot also created its Secure Boot
keys: reboot once more (the keys are enrolled then). Only when
`sudo sbctl status` shows `Vendor Keys: microsoft` (not `builtin-PK`)
switch Secure Boot on in the firmware; before that the laptop would go
black after the logo (`modules/boot/boot.md`). Then:

1. Log in as `zepzeper` (a TTY is fine: Ctrl+Alt+F2).
2. `sudo passwd <person>`: the colleague types their own password.
3. `enroll-tpm-pin` (with Secure Boot on; it checks): type the disk
   passphrase, then the colleague chooses their PIN (twice). From now on
   the laptop asks only that PIN at boot, also after system updates. After
   a firmware update that resets Secure Boot (or changes its keys) it asks
   the passphrase instead: enroll the keys again (`modules/boot/boot.md`)
   and run `enroll-tpm-pin` again.
4. `tailscale up` and log in with my account: the laptop joins the tailnet,
   and from then on `ssh <name>` reaches it from anywhere (my keys only;
   SSH stays closed on the networks it roams on). In the Tailscale admin
   console, turn off key expiry for it, so it never drops out.
5. Store the disk passphrase and the recovery key in the password manager
   under the laptop's name: with them the disk opens when the PIN is
   forgotten (then run `enroll-tpm-pin` again).
6. Log out; the colleague logs in. Apps beyond the standard set come from
   Discover (Flathub), no admin needed.

### Servers (unencrypted): from the desktop

With [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) (in
`nix develop`), from `~/personal/nix` on the desktop, with the server booted
into the installer, or into any Linux that root can SSH into (it switches
itself into a NixOS installer). It generates the hardware file, partitions
and installs, all over SSH. The hardware file has to exist in git first
(flakes only see tracked files), so start it empty:

```sh
nix develop
echo '{ }' > modules/hosts/servers/_<name>-hardware.nix
git add modules/hosts/servers/<name>.nix modules/hosts/servers/_<name>-hardware.nix
nixos-anywhere --flake .#<name> --target-host root@<address> \
  --phases kexec,disko,install \
  --generate-hardware-config nixos-generate-config modules/hosts/servers/_<name>-hardware.nix

# Commit and push the hardware file before the first boot: a server that
# follows main would otherwise pull a version without it.
git add modules/hosts/servers/_<name>-hardware.nix
git commit -m "<name>: installed" && git push

# My password (for sudo), set before the first boot, then reboot.
ssh -t root@<address> "nixos-enter --root /mnt -c 'passwd zepzeper'"
ssh root@<address> reboot

# The installed system has new SSH host keys: forget the installer's.
ssh-keygen -R <address>
```

Afterwards the server is deployed from the desktop (see Everyday use), or
follows main by itself (the test server).

### Hetzner Cloud servers

Step by step, with every check along the way: `modules/hosts/servers/staging.md`
(the test server; the same steps for any Hetzner server). In short:

1. In the Cloud Console create the server: x86 (CX, CPX or CCX; not the ARM
   CAX types), at least 4 GB of memory, any image (it is never used), with
   IPv4 and IPv6, and my SSH key (the public key from
   `modules/users/zepzeper/authorized_keys`, under Security -> SSH keys).
   Then boot it into the **Rescue system** (Rescue -> linux64, my key,
   Enable rescue & power cycle): nixos-anywhere cannot start its installer
   from Ubuntu, whose kernel refuses the unsigned installer kernel.
2. Host file: `templates/host-server-hetzner.nix` to
   `modules/hosts/servers/<name>.nix`, named by role; the IPv6 address (the
   /64 with `::1`) can be filled in now or later.
3. Install it as above, with `root@<ipv4>` as the target. The disk is
   `/dev/sda`, set by `zep.hetznerCloud`.
4. After the reboot: `ssh <ipv4>`, then `tailscale up` once (open the link).
   From then on `ssh <name>` works over the tailnet.

### Secrets on a new machine

A machine decrypts its secrets with its SSH host key, which only exists
after the install. Add it, and re-encrypt what the machine needs
(`secrets/README.md`):

```sh
ssh <name> cat /etc/ssh/ssh_host_ed25519_key.pub > secrets/hosts/<name>.pub
# list <name> on its secrets in secrets/agenix-rules.nix, then:
cd secrets && agenix -r -i identity.age && cd .. && git add -A && git commit -m "<name>: secrets"
```

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
mkdir -p /home/zepzeper/personal && cp -a /root/nix /home/zepzeper/personal/nix && chown -R zepzeper:users /home/zepzeper/personal
reboot
```

Commit and push the two files from `~/personal/nix` afterwards.

## Everyday use

```sh
# This machine (nh is on every machine; the path can be left out where the
# host sets programs.nh.flake, as zepzeper does):
nh os switch .               # build, show the package diff, switch

nix develop                  # nvd, nix-tree: look into generations and closures

# Another machine (servers; they only update themselves when they follow
# main, as the test server does):
nixos-rebuild switch --flake .#<host> --target-host <host> --ask-sudo-password
nh os build . -H <host>      # only build it, e.g. to check a change
```

Employee laptops pull `main` from GitHub by themselves, so a push to `main`
reaches them within a day. They get exactly what `flake.lock` pins, so
security fixes reach them when the lock is updated: merge Monday's "Update
inputs" pull request once its check is green (then `nh os switch` here, and
deploy the servers). By hand, any time:

```sh
nix flake update && nix flake check && git commit -am "Update inputs" && git push
```
