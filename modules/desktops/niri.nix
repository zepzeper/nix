{
  # niri, a scrollable-tiling Wayland compositor. For my own machines.
  #
  # Login is a text greeter (tuigreet on greetd) that starts niri-session.
  # nixpkgs' programs.niri brings the portals, polkit and gnome-keyring.
  #
  # The packages below are only what niri's default config calls, so a fresh
  # install is usable. They are replaced when my own niri config is ported.
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
          alacritty # Mod+T in the default config
          fuzzel # Mod+D in the default config
          swaylock # Super+Alt+L in the default config
        ];
      };
    };
}
