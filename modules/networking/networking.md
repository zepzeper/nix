# Networking

`networking` (`zep.networking`), in one of two modes:

- `networkmanager` - workstations and laptops. Admins and people are in the
  `networkmanager` group, so they can manage WiFi without sudo.
- `networkd` - servers. DHCP on every wired port; a host with a static
  address adds its own `systemd.network.networks` entry.
