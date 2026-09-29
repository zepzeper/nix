# Secrets

`agenix.nix` brings in agenix on every machine and gives modules
`secretFile "<name>"`: the encrypted file from `secrets/` at the root of
this repository, or null while it is missing (or this machine has no host
key there yet). The secrets, who can read them, and how to add or edit one
are in `secrets/README.md`.

| Secret | Declared in | Used for |
| --- | --- | --- |
| `tailscale-authkey` | `services/tailscale.nix` | automatic Tailscale login (`zep.tailscale.options.authKey`) |
| `intelephense` | `users/zepzeper/` | PHP language server licence |
| `ansible-vault` | `users/zepzeper/` | Ansible vault password |
| `kodai-env` | `services/kodai/` | Kodai's `.env` on the test server |
