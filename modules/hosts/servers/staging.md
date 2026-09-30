# staging: from nothing to a running Kodai

The test server: a Hetzner Cloud VM running `staging.nix`. Its NixOS
configuration follows `main` by itself; Kodai's Forgejo CI deploys the
application onto it. The site and Mailpit answer over the tailnet only; SSH
answers publicly (keys only), because CI deploys over it.

Everything runs from `~/personal/nix` on the desktop. Roughly 30 minutes,
most of it waiting on the install.

```
desktop ──nixos-anywhere──▶ staging  (once: installs NixOS)
GitHub main ◀──every 5 min── staging  (its configuration, by itself)
Forgejo CI ──ssh as deploy──▶ staging  (Kodai releases, on push to `staging`)
```

## 0. Before you start

- [ ] `git pull` in `~/personal/nix`, and the latest `check` run on GitHub
      is green.
- [ ] Optional, catches a build error before any disk is wiped (takes a
      while the first time):
      `nix build .#nixosConfigurations.staging.config.system.build.toplevel --no-link`

## 1. The deploy key (for Kodai's CI)

The key CI logs in with as `deploy`. Made once, kept outside the repository
(`.gitignore` refuses `*-deploy` files anyway):

```sh
ssh-keygen -t ed25519 -f ~/.ssh/kodai-deploy -N "" -C kodai-ci
cat ~/.ssh/kodai-deploy.pub
```

- Put that public line in `modules/services/kodai/deploy_keys` (one line;
  the comments explain the optional `from="<ip>"` prefix that makes it work
  only from the runner's address).
- Commit and push:
  `git add modules/services/kodai/deploy_keys && git commit -m "Kodai deploy key" && git push`
- Keep `~/.ssh/kodai-deploy` (the private half): it becomes a Forgejo secret
  in step 7. Store a copy in Bitwarden.

## 2. Create the server (Hetzner Cloud Console)

| Setting | Choose |
| --- | --- |
| Location | Nuremberg or Falkenstein (closest) |
| Image | **Ubuntu** (latest); only used to start the installer |
| Type | x86: **CX, CPX or CCX** (AMD or Intel, both fine); **at least 4 GB memory**, 40 GB disk or more. Not the ARM **CAX** types. |
| Networking | **IPv4 on** (GitHub has no IPv6: without it the server cannot fetch its own configuration); IPv6 on |
| SSH keys | my desktop key: `cat ~/.ssh/id_ed25519.pub` (the line in `modules/users/zepzeper/authorized_keys`), added under Security -> SSH keys |
| Firewall | none needed; if you add one, allow inbound TCP 22 (CI deploys over it) |
| Backups | optional |
| Name | `staging` |

Why 4 GB: following `main` means the server works out its own new
configuration, which takes 1.5-2 GB of memory.

Note its **IPv4 address** (below: `<ipv4>`) and its **IPv6 /64**.

Check you can log in with your key (no password asked):

```sh
ssh root@<ipv4> true
```

It asks for a password: the key was not selected at creation. Copy it with
the root password Hetzner emailed (`ssh-copy-id -i ~/.ssh/id_ed25519.pub
root@<ipv4>`), or rebuild the server with the key ticked.

UEFI or legacy BIOS does not matter: Hetzner VMs differ (a CX in Helsinki
boots BIOS), and the Hetzner block boots with GRUB, which does both.

## 3. Install NixOS

```sh
cd ~/personal/nix
nix develop                                   # nixos-anywhere

# The hardware file must exist in git before nixos-anywhere fills it in.
echo '{ }' > modules/hosts/servers/_staging-hardware.nix
git add modules/hosts/servers/_staging-hardware.nix

nixos-anywhere --flake .#staging --target-host root@<ipv4> \
  --phases kexec,disko,install \
  --generate-hardware-config nixos-generate-config modules/hosts/servers/_staging-hardware.nix
```

What happens: the server switches from Ubuntu into a NixOS installer
(kexec; the SSH connection drops and comes back), writes the hardware file
on the desktop, builds staging on the desktop, wipes `/dev/sda`, partitions
it and installs. It stops before rebooting.

## 4. Before the first boot

In this order: the server starts following `main` within 5 minutes of
booting, so `main` must have its hardware file first. (If `main` requires
pull requests on GitHub, merge one here instead of pushing, and reboot only
once it is merged; the same for the deploy key in step 1.)

```sh
# 1. The hardware file to main.
git add modules/hosts/servers/_staging-hardware.nix
git commit -m "staging: installed" && git push

# 2. My password on the server (for sudo).
ssh -t root@<ipv4> "nixos-enter --root /mnt -c 'passwd zepzeper'"

# 3. Boot NixOS.
ssh root@<ipv4> reboot

# 4. The installed system has its own SSH host key: forget the installer's.
ssh-keygen -R <ipv4>
```

## 5. First login and Tailscale

Give it a minute, then:

```sh
ssh <ipv4>                     # as zepzeper; accept the new host key
systemctl --failed             # expect: 0 loaded units listed
tailscale up                   # open the link it prints, log in
```

In the Tailscale admin console (Machines -> staging):

- **Disable key expiry**, so it never drops off the tailnet.
- Access controls: limit who may reach `staging` on ports 80 and 8025
  (Mailpit has no login). With the default "everyone can reach everything"
  policy, that is every device on the tailnet.

From now on `ssh staging` works over the tailnet too.

## 6. Check it follows main

Within 5 minutes of booting it rebuilds once from GitHub (the install was
built from a local tree, which has no commit to compare with). Then:

```sh
ssh staging
nixos-version --configuration-revision     # the commit it runs...
git -C ~/personal/nix rev-parse origin/main   # (on the desktop) ...equals main
systemctl list-timers nixos-upgrade.timer  # next check within 5 minutes
journalctl -u nixos-upgrade -n 30          # what the last check did
```

A change merged to `main` is live on staging within about 5 minutes. A
commit that fails to build is tried again hourly, not every 5 minutes.

Optional, any time: its IPv6 address. Cloud Console -> staging ->
Networking shows the /64; in `staging.nix` set
`options.ipv6 = "<the /64 with ::1>/64";`, push, and it applies itself.

## 7. Kodai's pipeline

In the Kodai repository on Forgejo: Settings -> Actions -> Secrets. Four
secrets:

| Secret | Value |
| --- | --- |
| `STAGING_HOST` | `<ipv4>` |
| `STAGING_SSH_KEY` | the whole of `~/.ssh/kodai-deploy` (the private key, including the BEGIN/END lines) |
| `STAGING_KNOWN_HOSTS` | the output of `ssh-keyscan -t ed25519 <ipv4>`; check it matches `ssh staging cat /etc/ssh/ssh_host_ed25519_key.pub` |
| `STAGING_ENV` | Kodai's `.env`, below |

`STAGING_ENV`:

```sh
APP_ENV=prod
APP_DEBUG=false
APP_URL=http://staging
APP_KEY=base64:<openssl rand -base64 32>
APP_TIMEZONE=Europe/Amsterdam

DB_DRIVER=mysql
DB_DATABASE=kodai
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=kodai
DB_PASSWORD=

MAIL_DSN=smtp://127.0.0.1:1025
MAIL_FROM_ADDRESS=kodai@staging
MAIL_FROM_NAME="Kodai (staging)"
MAIL_REPLY_TO=

CACHE_STORE=redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

API_HOST=
```

- A value with spaces needs quotes (`"Kodai (staging)"`): unquoted, Kodai
  refuses the whole file, and the deploy stops at the migration.
- `DB_HOST=localhost` (not 127.0.0.1) connects over the socket, where
  MariaDB knows the `kodai` user without a password. MariaDB does not
  listen on the network at all.
- `APP_KEY`: make it once (`openssl rand -base64 32`, with `base64:` in
  front), keep it in Bitwarden, and never change it: what Kodai encrypted
  with it (its OAuth signing keys, for one) is unreadable with another key.
- Mail goes to Mailpit: nothing leaves the server; read it at
  `http://staging:8025`.

The workflow itself lives in Kodai (`.forgejo/workflows/deploy.yml` and
`.forgejo/scripts/activate`, on the branch `deploy-staging` for now). It runs
on every push to Kodai's `staging` branch, so those two files have to be on
that branch: merge them into `master`, and create `staging` from it if it
does not exist yet.

## 8. First deploy

Push to `staging` (or Actions -> deploy -> Run workflow). The run builds the
release, uploads it, migrates and switches. Then:

- `http://staging`: the site.
- `http://staging:8025`: the mail it sent.
- Once, the first OAuth signing key (Kodai's own command):
  `ssh staging`, then
  `cd /srv/kodai/current && sudo -u kodai bash -c 'umask 0007 && php bin/kodai oauth:keys rotate --in=now'`
  (the umask keeps whatever it writes in the cache removable by later
  deploys; the same goes for any `bin/kodai` command run by hand)

What a deploy does, and what the server allows it: `modules/services/kodai/kodai.md`.

## Everyday

| I want to | Do |
| --- | --- |
| change the server | edit this repository, merge to `main`: live within ~5 minutes |
| deploy Kodai | push to Kodai's `staging` branch |
| see logs | `ssh staging`, then `journalctl -u phpfpm-kodai -u 'kodai-*' -f` (app), `journalctl -u nginx`, `journalctl -u nixos-upgrade` (its own updates) |
| roll back Kodai | point `current` at the previous release and restart (below) |
| roll back the server | revert the change on `main` (live within ~5 minutes). A quick `sudo nixos-rebuild switch --rollback` is undone within the hour, because the server follows `main` again; `sudo systemctl stop nixos-upgrade.timer` as well holds it until the next reboot |
| start over | install again from step 3: it wipes the disk (the database too) |

Rolling back Kodai by hand, on the server:

```sh
sudo -u deploy ls /srv/kodai/releases               # newest last
sudo -u deploy ln -sfn releases/<previous-id> /srv/kodai/current.new
sudo -u deploy mv -T /srv/kodai/current.new /srv/kodai/current
sudo systemctl reload phpfpm-kodai.service && sudo systemctl restart kodai.target
```

Migrations are not undone by this; a release that changed the database may
need its migration rolled back first, before switching:
`cd /srv/kodai/current && sudo -u deploy env DB_USERNAME=deploy php vendor/bin/phinx rollback`.

## When something goes wrong

| Symptom | Cause, fix |
| --- | --- |
| `ssh root@<ipv4>` asks for a password | The SSH key was not on the server at creation: step 2. |
| nixos-anywhere fails before "disko" | Nothing was wiped yet; fix and run it again (from `echo '{ }'` on). |
| nixos-anywhere fails during the build | A build error in the config: the optional `nix build` of step 0 shows it without touching the server. |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | The installer's host key: `ssh-keygen -R <ipv4>` (step 4). |
| `ssh <ipv4>`: Permission denied (publickey) | Not my key: the desktop's key must be in `modules/users/zepzeper/authorized_keys`. |
| `sudo`: wrong password | The password from step 4. Forgotten: root is locked, so the Console's "reset root password" does not help; reinstall from step 3 (wipes the database too). |
| `http://staging` does not load | Tailscale: `tailscale status` on the desktop shows staging? Access controls allow port 80? |
| `http://staging` gives 404 | Nothing deployed yet (no `/srv/kodai/current`): run the deploy. |
| `http://staging` gives 502 | PHP-FPM: `journalctl -u phpfpm-kodai -n 50`. |
| CI: `Permission denied (publickey)` for deploy | The deploy key is not on the server yet: `cat /etc/ssh/authorized_keys.d/deploy` on the server. It arrives within 5 minutes of pushing `deploy_keys`. |
| CI: `Host key verification failed` | `STAGING_KNOWN_HOSTS` holds an old key (e.g. the installer's): scan again after the reboot. |
| CI: migration fails | Nothing was switched; the old release keeps running. The output shows the SQL error. |
| staging stopped following main | `journalctl -u nixos-upgrade -n 50` on the server. |
