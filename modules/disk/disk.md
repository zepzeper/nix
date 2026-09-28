# Disk

`disk-layout` (`zep.disk`): the standard layout, declared with disko.

```
ESP 1G vfat /boot
[LUKS cryptroot]          options.encrypt (forced on laptops, refused on servers)
  BTRFS  @root /  @home /home  @nix /nix  @log /var/log  [@swap]
```

- `options.device` is required and erased at install. Use a
  `/dev/disk/by-id/` path so it does not change between boots.
- `options.recoveryKey` (on for laptops): disko enrolls a random recovery key
  at install and shows it once. Store it; it opens the disk when the
  passphrase is forgotten.
- `options.swapSize`: a swap file on its own subvolume. Without it there is
  no hibernation (zram covers memory pressure).
- The passphrase prompt at boot uses the keyboard layout of `zep.locale`.

The Raspberry Pi does not use this block (`zep.disk.enable = false`): it keeps
the SD image's partitions.
