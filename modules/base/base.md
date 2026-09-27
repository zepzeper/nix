# Base

What every machine has. `profiles-base` forces `nix`, `users`, `ssh` and
`hardening` on; `locale` is on by default.

| Block | Option | What |
| --- | --- | --- |
| `base-nix` | `zep.nix` | flakes, weekly GC, registry pinned to our nixpkgs, wheel may copy closures |
| `base-users` | `zep.users` | `admins` (wheel, SSH keys) and `people` (no wheel, password at handover); root locked |
| `base-ssh` | `zep.ssh` | key-only OpenSSH with a forced crypto floor |
| `base-locale` | `zep.locale` | time zone, language and regional formats separately, keyboard |
| `base-hardening` | `zep.hardening` | firewall, sudo for wheel only, sysctl baseline |
