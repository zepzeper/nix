# Kodai

`services-kodai` (`zep.kodai`) is the platform Kodai is deployed onto: the
services from its `compose.yaml`, declared here. It is not the
application: Kodai's own CI deploys the code and writes its `.env`; this
repository never sees either.

| This repository | Kodai's CI |
| --- | --- |
| PHP 8.5 and `php.ini`, PHP-FPM, nginx, MariaDB, Redis, Mailpit | the code, as a release |
| workers and scheduler (`kodai.target`), sandboxed | `.env` (from its secrets) |
| the `deploy` user and its key (`deploy_keys`) | `composer install`, migrations |
| `/srv/kodai/{releases,shared/var}`, permissions | switching `current`, restarting |
| firewall: site and Mailpit over the tailnet only | |

Files next to `kodai.nix`, edited as files: `php.ini` (PHP settings) and
`deploy_keys` (the public key CI deploys with).

## What a deploy does

CI logs in as `deploy` over SSH (a Forgejo secret holds the private key;
the login gets no terminal and no forwarding) and:

1. uploads the release (code plus `vendor/` from `composer install --no-dev
   --classmap-authoritative`) to `/srv/kodai/releases/<id>/`, and writes its
   `.env` from its secrets into it (mode 0640): the settings go live with
   the code, and a rollback takes its own `.env` along;
2. makes `public/` readable for nginx (`chmod o+x <release>`,
   `chmod -R o+rX <release>/public`; nginx is in no Kodai group, so it
   reads nothing else), and gives the release its own cache:
   `mkdir -p /srv/kodai/shared/var/<id>/cache`,
   `rm -rf <release>/var && ln -sfn /srv/kodai/shared/var/<id> <release>/var`
   (the old release's workers keep filling their own cache until they
   restart);
3. migrates, as the `deploy` database user (the app's own user `kodai` may
   only read and write rows):
   `cd <release> && DB_USERNAME=deploy php vendor/bin/phinx migrate`
   (a real environment variable beats `.env`);
4. switches: `ln -sfn releases/<id> /srv/kodai/current.new && mv -T
   /srv/kodai/current.new /srv/kodai/current` (atomic);
5. `systemctl reload phpfpm-kodai.service` (running requests get 10s to
   finish) and `systemctl restart kodai.target` - the only two root actions
   `deploy` may take (polkit, no sudo);
6. removes old releases and their caches, keeping the last few (rolling
   back is pointing `current` at the previous one, then step 5).

Kodai's `.forgejo/scripts/activate` does steps 2 to 6.

The `deploy_keys` line may carry its own options
(`from="203.0.113.7" ssh-ed25519 ...`, so the key works only from the
runner's address); `restrict` is added to them.

## The test server: staging

`modules/hosts/servers/staging.nix`, a Hetzner Cloud server. Its NixOS
configuration follows `main`: it checks every 5 minutes and rebuilds only
when `main` moved, so a merged change is live within minutes, with no key
for this repository anywhere else.

Once:

1. **Create it** in the Cloud Console: x86, Ubuntu image, IPv4 and IPv6, my
   SSH key. Optionally put its IPv6 /64 (with `::1`) in `staging.nix`.
2. **Deploy key**: create a key pair for Kodai's pipeline
   (`ssh-keygen -t ed25519 -f kodai-deploy -C kodai-ci`). The private half
   becomes a Forgejo secret of the Kodai repository; the public half goes in
   `deploy_keys`. Commit.
3. **Install** from `~/personal/nix` on the desktop:

   ```sh
   nix develop
   echo '{ }' > modules/hosts/servers/_staging-hardware.nix && git add -A
   nixos-anywhere --flake .#staging --target-host root@<ipv4> --no-reboot \
     --generate-hardware-config nixos-generate-config modules/hosts/servers/_staging-hardware.nix
   ssh -t root@<ipv4> "nixos-enter --root /mnt -c 'passwd zepzeper'"
   ssh root@<ipv4> reboot
   git add -A && git commit -m "staging: installed" && git push
   ```

4. **Tailnet**, for the site and Mailpit: `ssh <ipv4>`, then `tailscale up`.
   In the Tailscale admin console turn off key expiry for it, and limit who
   may reach its ports 80 and 8025 (Mailpit has no login).
5. **Kodai's pipeline** (`.forgejo/workflows/deploy.yml`: the `staging`
   branch deploys here) needs four secrets in the Kodai repository:

   | Secret | Is |
   | --- | --- |
   | `STAGING_HOST` | the server's IPv4 |
   | `STAGING_SSH_KEY` | the private half of `kodai-deploy` |
   | `STAGING_KNOWN_HOSTS` | `ssh-keyscan -t ed25519 <ipv4>` (compare with `ssh <ipv4> cat /etc/ssh/ssh_host_ed25519_key.pub`) |
   | `STAGING_ENV` | the whole `.env` (`DB_HOST=localhost` for the socket, `DB_USERNAME=kodai`, `DB_PASSWORD=` empty, `MAIL_DSN=smtp://127.0.0.1:1025`) |

Then: `http://staging` (the site), `http://staging:8025` (the mail). Logs:
`journalctl -u phpfpm-kodai -u 'kodai-*'`.
