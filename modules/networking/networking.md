# Networking

`networking` (`zep.networking`), in one of two modes:

- `networkmanager` - workstations and laptops. Admins and people are in the
  `networkmanager` group, so they can manage WiFi without sudo.
  `options.openvpn` (on for laptops) adds OpenVPN profiles to
  NetworkManager: import an `.ovpn` in the network settings, or with
  `nmcli connection import type openvpn file <profile>.ovpn`.
- `networkd` - servers. DHCP on every wired port through nixpkgs' own
  `99-ethernet-default-dhcp`. A host with a static address or a bridge adds
  `systemd.network.networks."10-<name>"`, which wins because networkd uses
  the first matching file by name.
