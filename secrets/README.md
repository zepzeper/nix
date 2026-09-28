# Secrets

Encrypted with [agenix](https://github.com/ryantm/agenix). Each secret is an
`.age` file here, encrypted to me and to the machines that use it. A machine
decrypts its secrets at boot with its own SSH host key, into `/run/agenix/`
(memory only); the plaintext never enters the Nix store or this repository.

| File | Is |
| --- | --- |
| `secrets.nix` | who can decrypt which secret (read by the `agenix` command) |
| `recipients/zepzeper.txt` | my age public key |
| `identity.age` | my age private key, locked with the passphrase in Bitwarden |
| `hosts/<machine>.pub` | a machine's SSH host key (`/etc/ssh/ssh_host_ed25519_key.pub`) |
| `<name>.age` | the secrets |

| Secret | Used by |
| --- | --- |
| `tailscale-authkey` | Tailscale, logs the machine in on its own (`zep.tailscale.options.authKey`) |
| `intelephense` | the PHP language server's licence, at `~/intelephense/license.txt` |
| `ansible-vault` | Ansible's vault password (`ANSIBLE_VAULT_PASSWORD_FILE`) |

A secret is only used on a machine once its `.age` file exists, so the
configuration builds before any secret has been added.

## First time: bring them over from zepzeper/dev

```sh
git clone https://github.com/zepzeper/dev ~/personal/dev   # if it is not there yet
~/personal/nix/secrets/import-from-dev ~/personal/dev      # asks the passphrase once
cd ~/personal/nix && git add secrets && git commit -m "Secrets" && git push
nh os switch
```

## Everyday

Run in this folder; the passphrase is asked when a secret is opened.

```sh
agenix -e <name>.age -i identity.age      # create or edit a secret
agenix -r -i identity.age                 # re-encrypt all after changing secrets.nix
```

A new secret: add a line to `secrets.nix`, create it with `agenix -e`, and
declare it where it is used (`age.secrets.<name>.file`).

A new machine: after its install, add its host key
(`/etc/ssh/ssh_host_ed25519_key.pub`) as `hosts/<machine>.pub`, list it on
the secrets it needs in `secrets.nix`, run `agenix -r -i identity.age`,
commit, and switch the machine.
