{
  # How apps look on the niri desktop: GTK, Qt, icons and the cursor, all
  # coloured by Noctalia's theme templates (noctalia.toml), so they follow
  # the wallpaper and dark/light mode together with the shell.
  #
  # - GTK: adw-gtk3 makes GTK3 apps look like libadwaita (GTK4) ones, and is
  #   what Noctalia's GTK template is written for. Noctalia writes
  #   noctalia.css next to gtk.css; the @import below loads it. Because the
  #   import is already there, Noctalia's hook leaves gtk.css (read-only
  #   here) alone and only switches dark/light through dconf.
  # - Qt: qt5ct/qt6ct with Noctalia's colour scheme on the Fusion style
  #   (Fusion follows the palette; Kvantum would ignore it).
  # - Icons: Papirus. Cursor: Bibata, as before (niri's config.kdl names it
  #   too).
  flake.modules.homeManager.desktops-niri-theme =
    {
      config,
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      desktop = osConfig.zep.desktop;
      active = desktop.enable && desktop.options.environment == "niri";

      noctaliaCss = ''@import url("noctalia.css");'';

      qtct = name: {
        Appearance = {
          style = "Fusion";
          custom_palette = true;
          color_scheme_path = "${config.xdg.configHome}/${name}/colors/noctalia.conf";
          icon_theme = "Papirus-Dark";
          standard_dialogs = "xdgdesktopportal";
        };
      };
    in
    {
      key = "zep#hm-desktops-niri-theme";
      config = lib.mkIf active {
        gtk = {
          enable = true;
          theme = {
            package = pkgs.adw-gtk3;
            name = "adw-gtk3-dark";
          };
          iconTheme = {
            package = pkgs.papirus-icon-theme;
            name = "Papirus-Dark";
          };
          gtk3.extraCss = noctaliaCss;
          gtk4.extraCss = noctaliaCss;
        };

        qt = {
          enable = true;
          platformTheme.name = "qtct";
          qt5ctSettings = qtct "qt5ct";
          qt6ctSettings = qtct "qt6ct";
        };

        home.pointerCursor = {
          enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
          gtk.enable = true;
        };
      };
    };
}
