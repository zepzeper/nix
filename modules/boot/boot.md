# Boot

`boot-loader` (`zep.boot`): systemd-boot for UEFI machines, or extlinux for
ARM servers that boot through U-Boot (`options.loader`).
Keeps 10 generations in the menu by default; the boot menu editor is off.
systemd runs in the initrd for every loader (the scripted initrd is
deprecated), which TPM2 and FIDO2 disk unlock will need later.

`options.secureBoot` (on for workstations and laptops, through lanzaboote):
Secure Boot with the machine's own keys, which it creates and enrolls by
itself (with Microsoft's, which graphics cards' firmware needs). The first
switch with it creates the keys and signs the boot files; then put Secure
Boot in Setup Mode in the firmware settings, and at the next boot the keys
are enrolled (if the firmware already is in Setup Mode, that happens at the
very next reboot, without asking). Check with `sbctl status` and
`sbctl verify`. Servers do without (no one to watch the firmware, and
Hetzner VMs have no Secure Boot).

Moving a machine that already booted with plain systemd-boot: lanzaboote
removes the old generations' kernels but not their menu entries, which
then fail to boot. After that first switch:

```sh
sudo rm /boot/loader/entries/nixos-generation-*.conf
bootctl list      # only lanzaboote's entries left
```

Firmware (BIOS) updates through fwupd boot a program that is not signed
with the machine's key; with Secure Boot on, sign it first
(`sudo sbctl sign -s <path of fwupdx64.efi>`) or update the firmware from
its own menu.
