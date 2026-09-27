# Boot

`boot-loader` (`zep.boot`): systemd-boot for UEFI machines, or extlinux for
boards like the Raspberry Pi (`options.loader`). Keeps 10 generations in the
menu by default. systemd runs in the initrd on UEFI machines, which TPM2 and
FIDO2 disk unlock will need later.
