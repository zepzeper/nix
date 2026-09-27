{
  # GNOME, with GDM as the login screen. The alternative for employee
  # laptops: cleaner and more opinionated, closer to macOS.
  flake.modules.nixos.desktops-gnome =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zep.desktop;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.options.environment == "gnome") {
        services.desktopManager.gnome.enable = true;
        services.displayManager.gdm.enable = true;

        # The welcome tour is for a first install, not a managed laptop.
        environment.gnome.excludePackages = [ pkgs.gnome-tour ];
      };
    };
}
