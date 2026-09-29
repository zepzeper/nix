# Kodai

`services-kodai` (`zep.kodai`): Kodai on a server, natively (no Docker). See
`kodai.nix` for what runs; the files next to it are edited as files:

| File | Is |
| --- | --- |
| `php.ini` | PHP settings (Kodai's production values, plus the MariaDB socket) |
| `deploy` | `kodai-deploy`, run on the server |
| `env.example` | what goes in the `kodai-env` secret, Kodai's `.env` |

Only over the tailnet: the site on port 80, Mailpit's inbox on 8025. Mail is
caught, never delivered.

## The test server: staging

`modules/hosts/servers/staging.nix`, a Hetzner Cloud server. Once:

1. **Create it** in the Cloud Console: x86, Ubuntu image, IPv4 and IPv6, my
   SSH key. Optionally put its IPv6 /64 (with `::1`) in `staging.nix`.
2. **Install** from `~/personal/nix` on the desktop:

   ```sh
   nix develop
   echo '{ }' > modules/hosts/servers/_staging-hardware.nix && git add -A
   nixos-anywhere --flake .#staging --target-host root@<ipv4> --no-reboot \
     --generate-hardware-config nixos-generate-config modules/hosts/servers/_staging-hardware.nix
   ssh -t root@<ipv4> "nixos-enter --root /mnt -c 'passwd zepzeper'"
   ssh root@<ipv4> reboot
   ```

3. **Tailnet**: `ssh <ipv4>`, then `tailscale up` (open the link). From now
   on it is `staging`. In the Tailscale admin console turn off key expiry
   for it (or it drops off the tailnet after 180 days), and limit who may
   reach its ports 80 and 8025: Mailpit has no login, and employee laptops
   are on the same tailnet.
4. **Its .env** (secrets/README.md):

   ```sh
   ssh staging cat /etc/ssh/ssh_host_ed25519_key.pub > secrets/hosts/staging.pub
   cd secrets && agenix -e kodai-env.age -i identity.age && cd ..
   ```

   Paste `env.example` into the editor; set `APP_URL` to
   `http://staging.<your-tailnet>.ts.net` and a new `APP_KEY`
   (`echo "base64:$(openssl rand -base64 32)"`). Then commit (hardware file,
   host key, secret), push, and deploy the configuration:

   ```sh
   git add -A && git commit -m "staging: installed" && git push
   nixos-rebuild switch --flake .#staging --target-host staging --ask-sudo-password
   ```

5. **Deploy key**: `ssh -t staging kodai-deploy --key` prints the server's
   key; add it on GitHub (zepzeper/kodai -> Settings -> Deploy keys,
   read-only).

## Deploying

```sh
ssh -t staging kodai-deploy main      # a branch, a tag (v1.2.3) or a commit
```

It fetches the code into `/srv/kodai`, installs the dependencies (no dev
ones), runs the migrations, reloads PHP-FPM and restarts the workers and the
scheduler. `-t` because sudo asks my password for the reload.

Then: `http://staging` (the site), `http://staging:8025` (the mail). Logs:
`journalctl -u phpfpm-kodai -u 'kodai-*'`.
