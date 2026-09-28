# Services

`services-auto-update` (`zep.autoUpdate`): the machine pulls
`github:zepzeper/nix#<hostname>` on a schedule, builds it and switches.

- Employee laptops: on, daily, never reboots by itself.
- Servers: off, forced. They change only when an admin deploys to them.
- My own machines: off unless a host turns it on.

What a machine updates *to* is pinned by `flake.lock`: bump it and push to
ship security fixes.

`services-tailscale` (`zep.tailscale`): the machine joins the tailnet. Log
in once with `sudo tailscale up`, or let it log itself in with the auth key
secret (`options.authKey`, see `secrets/README.md`). DNS goes through
systemd-resolved so MagicDNS names work next to NetworkManager.
