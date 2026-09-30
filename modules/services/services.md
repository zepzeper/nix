# Services

`services-auto-update` (`zep.autoUpdate`): the machine pulls
`github:zepzeper/nix#<host>` (its name in this flake) on a schedule, builds it and switches.

- Employee laptops: on, daily, never reboots by itself.
- Servers: off by default. They change when an admin deploys to them; a
  server can follow main instead (the test server does, see below).
- My own machines: off unless a host turns it on.

What a machine updates *to* is pinned by `flake.lock`: bump it and push to
ship security fixes.

`services-tailscale` (`zep.tailscale`): the machine joins the tailnet. Log
in once with `sudo tailscale up`, or let it log itself in with the auth key
secret (`options.authKey`, see `secrets/README.md`). SSH always answers
over the tailnet, also where it is closed to the network (laptops). DNS
goes through systemd-resolved so MagicDNS names work next to
NetworkManager.

`services-printing` (`zep.printing`, on for laptops): printing and scanning.
Network printers and scanners are found by themselves (Avahi, driverless
IPP and eSCL); USB ones through ipp-usb. Admins and people can print and
scan without sudo.

`services-kodai` (`zep.kodai`): the platform Kodai is deployed onto
(PHP-FPM, nginx, MariaDB, Redis, Mailpit, sandboxed workers), over the
tailnet only. Kodai's CI deploys the code and its `.env`. See
`kodai/kodai.md`.

`services-auto-update` can also make a server follow main
(`options.onlyWhenChanged` with a short schedule): it checks every few
minutes and rebuilds only when main moved. The test server does this.
A commit that fails to build is retried hourly, not every few minutes. A
switch to anything that is not main (a local build) lasts until the next
check: main replaces it.
