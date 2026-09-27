# Profiles

A profile is a machine type. A host imports exactly one.

| Profile | Imports | Forces | Defaults |
| --- | --- | --- | --- |
| `profiles-base` | every block | nix, users, ssh, hardening | locale, boot, disk, hardware, networking on |
| `profiles-workstation` | base | | NetworkManager |
| `profiles-laptop` | workstation | disk encryption, no automatic reboot | auto-update on, power-profiles-daemon |
| `profiles-server` | base | no audio, no bluetooth | networkd, auto-update with reboot window, no docs |

When a new block is written, add it to the imports in `base.nix`, and switch
it on in the profile that needs it with `lib.mkDefault` (or `lib.mkForce` if
that machine type must have it).
