# Base

What every machine has. `profiles-base` forces `nix`, `users`, `ssh` and
`hardening` on; `locale` is on by default.

| Block | Option | What |
| --- | --- | --- |
| `base-nix` | `zep.nix` | flakes, weekly GC, store optimisation, git (flakes need it), nh (`nh os switch`), `pkgs.unstable`; `options.trustAdmins` (servers only) makes wheel a trusted Nix user for remote deploys. The registry and NIX_PATH follow the host's own channel (nixpkgs does that itself) |
| `base-users` | `zep.users` | `admins` (wheel, SSH keys) and `people` (no admin groups, password at handover); root starts locked |
| `base-ssh` | `zep.ssh` | OpenSSH: wheel only, keys from this repo only, no root, no passwords; crypto left to nixpkgs; `options.openFirewall` (off on laptops) |
| `base-locale` | `zep.locale` | time zone, language and regional formats separately, keyboard layout and variant |
| `base-hardening` | `zep.hardening` | firewall, sudo for wheel only, sysctl baseline |
