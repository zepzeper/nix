{
  config,
  pkgs,
  ...
}: {
fileSystems."/mnt/hdd" = {
  device = "/dev/disk/by-uuid/938f2c14-62a8-41e3-b67b-dd8785881bbd";
  fsType = "ext4";
  options = [ "defaults" "nofail" ];
};
}
