{
  # niri with the Noctalia shell: the user half (see niri.nix for the system
  # half). Given to every Home Manager user, active only on machines whose
  # desktop is niri.
  #
  # - niri's config: config.kdl in this folder, checked with `niri validate`
  #   when the system is built, so a typo fails the build instead of the
  #   session. ~/.config/niri/local.kdl is included for live experiments.
  # - Noctalia: bar, launcher, notifications, lock screen, idle, wallpaper,
  #   OSD, clipboard history, screenshots, night light, session menu, and the
  #   polkit password dialog. Runs as a systemd user service tied to the
  #   niri session; restarts when its settings change. Settings here are
  #   defaults: anything changed in Noctalia's own settings window is kept in
  #   ~/.local/state/noctalia/settings.toml and wins over them.
  # - ghostty, the terminal.
  flake.modules.homeManager.desktops-niri =
    {
      lib,
      pkgs,
      options,
      osConfig,
      ...
    }:
    let
      desktop = osConfig.zep.desktop;
      active = desktop.enable && desktop.options.environment == "niri";

      niriConfig = pkgs.runCommand "niri-config.kdl" { } ''
        ${lib.getExe osConfig.programs.niri.package} validate -c ${./config.kdl}
        cp ${./config.kdl} $out
      '';
    in
    {
      key = "zep#hm-desktops-niri";
      config = lib.mkIf active (
        lib.mkMerge [
          {
            xdg.configFile."niri/config.kdl".source = niriConfig;

            programs.ghostty = {
              enable = true;
              settings = {
                font-family = "JetBrainsMonoNL Nerd Font Mono";
                font-size = 12;
                theme = "Rose Pine Moon";
                background = "161521";
                window-decoration = "none";
                gtk-titlebar = false;
                confirm-close-surface = false;
                keybind = [ "ctrl+enter=unbind" ];
              };
            };

            home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
            fonts.fontconfig.enable = true;
          }

          # Home Manager's Noctalia module exists on the unstable channel
          # only; niri.nix already refuses niri on stable.
          (lib.optionalAttrs (options.programs ? noctalia) {
            programs.noctalia = {
              enable = true;
              systemd.enable = true;
              settings = {
                shell = {
                  # The password dialog for admin actions; niri has none.
                  polkit_agent = true;
                  telemetry_enabled = false;
                  # Apps started from Noctalia survive a Noctalia restart.
                  launch_apps_as_systemd_services = true;
                };
                theme.mode = "dark";
                # Lock after 10 minutes, screens off a minute later. The
                # lock screen also comes up before every suspend.
                idle.behavior = {
                  lock = {
                    timeout = 600;
                    action = "lock";
                    enabled = true;
                  };
                  screen-off = {
                    timeout = 660;
                    action = "screen_off";
                    enabled = true;
                  };
                };
              };
            };
          })
        ]
      );
    };
}
