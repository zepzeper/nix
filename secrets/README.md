# Secrets

Encrypted with [agenix](https://github.com/ryantm/agenix). Each secret is an
`.age` file here, encrypted to me and to the machines that use it. A machine
decrypts its secrets at boot with its own SSH host key, into `/run/agenix/`
(memory only); the plaintext never enters the Nix store or this repository.

| File | Is |
| --- | --- |
| `agenix-rules.nix` | who can decrypt which secret (read by the `agenix` command) |
| `recipients/zepzeper.txt` | my age public key |
| `identity.age` | my age private key, locked with the passphrase in Bitwarden (the same file as in zepzeper/dev) |
| `hosts/<machine>.pub` | a machine's SSH host key (`/etc/ssh/ssh_host_ed25519_key.pub`) |
| `<name>.age` | the secrets |

| Secret | Used by |
| --- | --- |
| `tailscale-authkey` | Tailscale logging in by itself, where a host sets `zep.tailscale.options.authKey` |
| `intelephense` | the PHP language server's licence, linked to `~/intelephense/license.txt` |
| `ansible-vault` | Ansible's vault password (`ANSIBLE_VAULT_PASSWORD_FILE`) |

A machine only uses a secret once the `.age` file is committed (flakes see
only files git knows about) and the machine's host key is in `hosts/`. So the
configuration builds before any secret exists. `.gitignore` here lets only
encrypted files and public keys be committed.

Not brought over from zepzeper/dev: `sshkey` (each machine has its own SSH
key now) and `restic-password` (comes with the backups).

## Everyday

Run in this folder. The passphrase is asked each time a secret is opened
(so once per secret for `-r`).

```sh
agenix -e <name>.age -i identity.age      # create or edit a secret
agenix -r -i identity.age                 # re-encrypt all after changing agenix-rules.nix
```

A new secret: add it to `agenix-rules.nix`, create it with `agenix -e`,
`git add` it, and declare it where it is used (`secretFile "<name>"`, see
`modules/secrets/agenix.nix`).

A new machine: after its install, add its host key as `hosts/<machine>.pub`,
list it on the secrets it needs in `agenix-rules.nix`, run
`agenix -r -i identity.age`, commit, and switch the machine.
`nix flake check` (and CI) fails if a machine is listed but the secret was
not re-encrypted for it.
