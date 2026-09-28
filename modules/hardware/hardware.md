# Hardware

`hardware-base` (`zep.hardware`): redistributable firmware, zram swap, weekly
fstrim, and firmware updates through fwupd (`options.firmwareUpdates`, off on
servers). Model specifics live with the host: its generated
`_<name>-hardware.nix`, or a nixos-hardware profile when one exists.
