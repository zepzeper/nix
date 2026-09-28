{
  # niri, a scrollable-tiling Wayland compositor. For my own machines.
  #
  # Login is a text greeter (tuigreet on greetd) that starts niri-session.
  # nixpkgs' programs.niri brings the portals, the polkit daemon and
  # gnome-keyring. It does not start a polkit *agent* (the password dialog
  # for admin actions), so one runs as a user service here.
  #
  # The packages below are what niri's default config calls, so a fresh
  # install is usable: bar, launcher, terminal, locker, notifications,
  # media and brightness keys. They are replaced when my own niri config is
  # ported.
  flake.modules.nixos.desktops-niri =
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
      key = "zep#desktops-niri";
      config = lib.mkIf (cfg.enable && cfg.options.environment == "niri") {
        programs.niri.enable = true;

        services.greetd = {
          enable = true;
          useTextGreeter = true;
          settings.default_session.command = lib.concatStringsSep " " [
            (lib.getExe pkgs.tuigreet)
            "--time"
            "--remember"
            "--asterisks"
            "--cmd niri-session"
          ];
        };

        environment.systemPackages = with pkgs; [
          # X11 apps: niri starts xwayland-satellite on demand when it is on
          # the PATH. niri has no X11 session of its own.
          xwayland-satellite
          alacritty # Mod+T
          fuzzel # Mod+D
          swaylock # Super+Alt+L
          waybar # spawn-at-startup
          mako # notifications (the portal's Notification backend needs one)
          playerctl # media keys
          brightnessctl # brightness keys
        ];

        # The password dialog for admin actions. programs.niri runs the polkit
        # daemon but no agent; without one, anything asking for admin rights
        # from the GUI silently fails. (mako needs no service: D-Bus starts
        # it on the first notification.)
        systemd.user.services.polkit-agent = {
          description = "polkit authentication agent";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
          };
        };
      };
    };
}
