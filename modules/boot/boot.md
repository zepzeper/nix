# Boot

`boot-loader` (`zep.boot`): systemd-boot for UEFI machines, or extlinux for
ARM servers that boot through U-Boot (`options.loader`).
Keeps 10 generations in the menu by default; the boot menu editor is off.
systemd runs in the initrd for every loader (the scripted initrd is
deprecated), which TPM2 and FIDO2 disk unlock will need later.

`options.secureBoot` (on for workstations and laptops, through lanzaboote):
Secure Boot with the machine's own keys, which it creates and enrolls by
itself (with Microsoft's, which graphics cards' firmware needs). After the
first switch or boot with it: reboot once, then put Secure Boot in Setup
Mode in the firmware settings; at the next boot the keys are enrolled.
Check with `sbctl status`. Servers do without (no one to watch the
firmware, and Hetzner VMs have no Secure Boot).
