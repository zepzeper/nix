{
  # What every machine wants regardless of model: firmware, firmware updates,
  # compressed RAM swap. A host adds its model specifics (a nixos-hardware
  # profile, or its generated hardware configuration) on top.
  flake.modules.nixos.hardware-base =
    { config, lib, ... }:
    let
      cfg = config.zep.hardware;
    in
    {
      key = "zep#hardware-base";
      options.zep.hardware = {
        enable = lib.mkEnableOption "hardware baseline (firmware, fwupd, zram)";

        options.firmwareUpdates = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "fwupd: firmware updates from LVFS (BIOS, SSD, docks). Off on servers.";
        };
      };

      config = lib.mkIf cfg.enable {
        hardware.enableRedistributableFirmware = lib.mkDefault true;
        services.fwupd.enable = lib.mkDefault cfg.options.firmwareUpdates;
        zramSwap.enable = lib.mkDefault true;
        services.fstrim.enable = lib.mkDefault true;
      };
    };
}
