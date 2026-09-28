# Boot

`boot-loader` (`zep.boot`): systemd-boot for UEFI machines, or extlinux for
boards like the Raspberry Pi that boot through U-Boot (`options.loader`).
Keeps 10 generations in the menu by default; the boot menu editor is off.
systemd runs in the initrd for every loader (the scripted initrd is
deprecated), which TPM2 and FIDO2 disk unlock will need later.
