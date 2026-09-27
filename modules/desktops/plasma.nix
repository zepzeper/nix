{
  # KDE Plasma 6 on Wayland, with SDDM as the login screen. The default for
  # employee laptops: a taskbar and start menu, closest to what people know
  # from Windows.
  flake.modules.nixos.desktops-plasma =
    { config, lib, ... }:
    let
      cfg = config.zep.desktop;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.options.environment == "plasma") {
        services.desktopManager.plasma6.enable = true;

        services.displayManager.sddm = {
          enable = true;
          wayland.enable = true;
        };
      };
    };
}
