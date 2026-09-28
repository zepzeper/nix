# Hardware

- `hardware-base` (`zep.hardware`): redistributable firmware, zram swap,
  weekly fstrim, and firmware updates through fwupd
  (`options.firmwareUpdates`, off on servers).
- `hardware-graphics` (`zep.graphics`, on for workstations and laptops): the
  host names its GPU with `options.gpu` (`"intel"`, `"amd"`, `"nvidia"`).
  For NVIDIA, `options.nvidiaGeneration` picks driver and kernel module:
  `"turing-or-newer"` (RTX, GTX 16xx: current driver, open module) or
  `"pascal-or-maxwell"` (GTX 9xx/10xx: 580 legacy branch, closed module).
  NVIDIA also gets modesetting, video memory kept across suspend, VA-API
  video decoding, and niri's fix for its video-memory use.

- `hardware-hetzner-cloud` (`zep.hetznerCloud`): a Hetzner Cloud x86 VM.
  The disk is `/dev/sda`; IPv4 by DHCP and the fixed IPv6 address from
  `options.ipv6` (gateway `fe80::1`), on systemd-networkd; QEMU guest
  drivers. Template: `templates/host-server-hetzner.nix`.

Model specifics live with the host: its generated `_<name>-hardware.nix`, or
a nixos-hardware profile when one exists.
