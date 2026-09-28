{
  # niri with the Noctalia shell, for my own machines. This is the system
  # half; the user half (niri's config, Noctalia, the terminal) is home.nix
  # in this folder.
  #
  # Here: niri itself, the login screen (tuigreet on greetd, starting
  # niri-session), X11 apps (xwayland-satellite, which niri starts on
  # demand), screen recording, and the system services Noctalia's widgets
  # read from (battery, power profiles; network and bluetooth are on
  # already).
  #
  # nixpkgs' programs.niri brings the portals (screencast, file picker),
  # the polkit daemon and gnome-keyring. The polkit *agent* - the password
  # dialog - is Noctalia's own (shell.polkit_agent in home.nix).
  #
  # Unstable only: Noctalia 5 is not in the 26.05 release.
  #
  # zep.niri.options.outputs: this machine's monitors, as niri `output`
  # blocks, set in its host file. home.nix turns it into outputs.kdl.
  flake.modules.nixos.desktops-niri =
    {
      config,
      lib,
      pkgs,
      hostConfig,
      ...
    }:
    let
      cfg = config.zep.desktop;

      # Ctrl+Shift+R: start recording the screen, or stop and save. The
      # screen (or window) is picked through the portal on start.
      record = pkgs.writeShellApplication {
        name = "zep-record";
        runtimeInputs = with pkgs; [
          coreutils
          libnotify
          procps
        ];
        # gpu-screen-recorder itself comes from PATH: programs.gpu-screen-recorder
        # installs it with the capabilities it needs in /run/wrappers/bin.
        text = ''
          if pkill -INT -f -- "gpu-screen-recorder -w portal"; then
            notify-send --app-name=Recorder "Recording saved" "$HOME/Videos/Recordings"
            exit 0
          fi
          dir="$HOME/Videos/Recordings"
          mkdir -p "$dir"
          notify-send --app-name=Recorder "Recording" "Ctrl+Shift+R again to stop"
          exec gpu-screen-recorder -w portal -f 60 -a default_output \
            -o "$dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"
        '';
      };
    in
    {
      key = "zep#desktops-niri";

      options.zep.niri.options.outputs = lib.mkOption {
        type = lib.types.lines;
        default = "";
        example = ''
          output "DP-1" {
              scale 1.6
          }
        '';
        description = ''
          niri `output` blocks for this machine's monitors (names from
          `niri msg outputs`). Empty: niri picks mode and scale itself.
        '';
      };

      config = lib.mkIf (cfg.enable && cfg.options.environment == "niri") {
        assertions = [
          {
            assertion = hostConfig.channel == "unstable";
            message = "${hostConfig.name}: niri with Noctalia needs the unstable channel (Noctalia 5 is not in 26.05). Set zep.hosts.${hostConfig.name}.channel = \"unstable\".";
          }
        ];

        programs = {
          niri.enable = true;
          # dconf (Noctalia's theme switches GTK dark/light through it) comes
          # with programs.niri.
          gpu-screen-recorder.enable = true;
        };

        services = {
          greetd = {
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

          # What Noctalia's battery and power widgets talk to.
          upower.enable = lib.mkDefault true;
          power-profiles-daemon.enable = lib.mkDefault true;
        };

        # Electron apps (VS Code, Slack, Discord, ...) run natively on
        # Wayland instead of through XWayland: sharp on scaled screens.
        environment.sessionVariables.NIXOS_OZONE_WL = "1";

        environment.systemPackages = [
          pkgs.xwayland-satellite
          # Also the file picker behind niri's portal (programs.niri.useNautilus).
          pkgs.nautilus
          record
        ];
      };
    };
}
