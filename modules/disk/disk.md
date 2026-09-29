# Disk

`disk-layout` (`zep.disk`): the standard layout, declared with disko.

```
ESP 1G vfat /boot
[LUKS cryptroot]          options.encrypt (forced on workstations and laptops, refused on servers)
  BTRFS  @root /  @home /home  @nix /nix  @log /var/log  [@swap]
```

- `options.device` is required and erased at install. Use a
  `/dev/disk/by-id/` path so it does not change between boots.
- `options.recoveryKey` (on for workstations and laptops): disko enrolls a random recovery key
  at install and shows it once. Store it; it opens the disk when the
  passphrase is forgotten.
- `options.tpm2` (on for laptops): the disk unlocks through the TPM after a
  short PIN. Set up on the machine with `enroll-tpm-pin` (the script is
  `scripts/enroll-tpm-pin`); until then, and whenever the TPM refuses
  (after a firmware or Secure Boot change), the passphrase is asked.
- `options.swapSize`: a swap file on its own subvolume. Without it there is
  no hibernation (zram covers memory pressure).
- The passphrase prompt at boot uses the keyboard layout of `zep.locale`.

An ARM server does not use this block (`zep.disk.enable = false`): it keeps
the SD image's partitions.
