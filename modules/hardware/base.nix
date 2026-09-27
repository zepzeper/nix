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
      options.zep.hardware = {
        enable = lib.mkEnableOption "hardware baseline (firmware, fwupd, zram)";
      };

      config = lib.mkIf cfg.enable {
        hardware.enableRedistributableFirmware = lib.mkDefault true;
        services.fwupd.enable = lib.mkDefault true;
        zramSwap.enable = lib.mkDefault true;
        services.fstrim.enable = lib.mkDefault true;
      };
    };
}
