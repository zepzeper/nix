# Profiles

A profile is a machine type. A host imports one (importing more is harmless,
every module has a key, but one is the convention).

| Profile | Imports | Forces | Defaults |
| --- | --- | --- | --- |
| `profiles-base` | every block, automatically | nix, users, ssh, hardening | locale, boot, disk, hardware, networking on |
| `profiles-workstation` | base | disk encryption | NetworkManager, a desktop (the host picks which), graphics drivers, recovery key |
| `profiles-laptop` | workstation | stable channel, no automatic reboot | Plasma, SSH closed to the network, auto-update on, Firefox, LibreOffice, printing and scanning, OpenVPN in NetworkManager |
| `profiles-server` | base | stable channel, unencrypted disk, no desktop, no automatic updates, no audio, no bluetooth | networkd, wheel trusted for remote deploys, no fwupd, no docs |

A new block is imported by `base.nix` automatically. Switch it on in the
profile that needs it with `lib.mkDefault` (or `lib.mkForce` if that machine
type must have it).
