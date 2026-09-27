# Disk

`disk-layout` (`zep.disk`): the standard layout, declared with disko.

```
ESP 1G vfat /boot
[LUKS cryptroot]          options.encrypt (forced on laptops)
  BTRFS  @root /  @home /home  @nix /nix  @log /var/log  [@swap]
```

`options.device` is required and erased at install. Use a
`/dev/disk/by-id/` path so it does not change between boots.
