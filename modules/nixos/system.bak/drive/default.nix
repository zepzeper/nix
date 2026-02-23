{
  config,
  pkgs,
  ...
}: {
  fileSystems."/run/media/zepzeper/hdd" = {
    device = "/dev/disk/by-uuid/938f2c14-62a8-41e3-b67b-dd8785881bbd";
    fsType = "ext4";
    options = ["defaults" "nofail"];
  };
}
