# Services

`services-auto-update` (`zep.autoUpdate`): the machine pulls
`github:zepzeper/nix#<hostname>` on a schedule, builds it and switches.
On for laptops (never reboots by itself) and servers (may reboot between
03:00 and 05:00).
