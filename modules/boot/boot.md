# Boot

`boot-loader` (`zep.boot`): systemd-boot for UEFI machines, or extlinux for
ARM servers that boot through U-Boot (`options.loader`).
Keeps 10 generations in the menu by default; the boot menu editor is off.
systemd runs in the initrd for every loader (the scripted initrd is
deprecated), which TPM2 and FIDO2 disk unlock will need later.

`options.secureBoot` (on for workstations and laptops, through lanzaboote):
Secure Boot with the machine's own keys, which it creates and enrolls by
itself (with Microsoft's, which graphics cards' firmware needs). Servers do
without (no one to watch the firmware, and Hetzner VMs have no Secure
Boot).

Setting it up, in this order. **Never turn Secure Boot on before step 3
shows your keys**: the firmware then refuses the boot loader and the
machine goes black after the logo (fix: turn Secure Boot off again).

1. Switch with it (or install). This creates the keys and signs the boot
   files; the machine still boots with Secure Boot off.
2. In the firmware settings, with Secure Boot still off, clear its keys
   (on ASRock: Security -> Secure Boot -> Secure Boot Mode: Custom -> Key
   Management -> Clear Secure Boot Keys). That is Setup Mode. Reboot into
   NixOS: systemd-boot enrolls the keys and restarts by itself.
3. `sudo sbctl status` shows `Setup Mode: Disabled` and `Vendor Keys:
   microsoft` (not `builtin-PK`, which are the factory keys).
4. Now turn Secure Boot on in the firmware. `sbctl status` then shows
   `Secure Boot: Enabled`, and `sbctl verify` that every boot file is
   signed.

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
