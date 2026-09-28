{
  # Which desktop a machine runs, and what every desktop needs.
  #
  #   zep.desktop.enable                on for workstations and laptops
  #   zep.desktop.options.environment   "niri" | "plasma" | "gnome"
  #
  # A machine runs exactly one: it is a single setting, so two desktops at
  # once cannot happen. Each environment lives in its own file in this folder
  # and switches itself on when it is the one chosen.
  #
  # Shared here: sound (PipeWire), bluetooth and fonts.
  #
  # X11. Every desktop here is Wayland; X11 apps run through XWayland on all
  # three (Plasma via programs.xwayland, GNOME's mutter has it built in, niri
  # through xwayland-satellite). A full X11 *session* as a fallback only
  # exists for Plasma: GNOME removed its X11 session in 49 and niri never had
  # one. KDE has announced Plasma will drop its X11 session too (6.8), so
  # options.x11Session is a bridge, not a plan.
  flake.modules.nixos.desktop =
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
      key = "zep#desktop";
      options.zep.desktop = {
        enable = lib.mkEnableOption "a graphical desktop";

        options.environment = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.enum [
              "niri"
              "plasma"
              "gnome"
            ]
          );
          default = null;
          description = ''
            The desktop this machine runs. niri is a tiling window manager
            for people who want one; Plasma and GNOME are full desktops for
            everybody else.
          '';
        };

        options.x11Session = lib.mkOption {
          type = lib.types.bool;
          default = cfg.options.environment == "plasma";
          defaultText = lib.literalExpression ''config.zep.desktop.options.environment == "plasma"'';
          description = ''
            Offer "Plasma (X11)" at the login screen as a fallback for the rare
            app or GPU that misbehaves under Wayland. Enables Xorg. Only
            Plasma has an X11 session; for anything else this must stay off.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.options.environment != null;
            message = ''zep.desktop is on but no desktop is chosen: set zep.desktop.options.environment to "niri", "plasma" or "gnome".'';
          }
          {
            assertion = cfg.options.x11Session -> cfg.options.environment == "plasma";
            message = "zep.desktop.options.x11Session: only Plasma has an X11 session (GNOME removed it in 49, niri is Wayland-only). X11 apps still work everywhere through XWayland.";
          }
        ];

        services = {
          # Xorg, only so the "Plasma (X11)" session at the login screen works.
          # Without xterm, which would otherwise appear in the start menu.
          xserver = lib.mkIf cfg.options.x11Session {
            enable = true;
            excludePackages = [ pkgs.xterm ];
          };

          # Sound
          pulseaudio.enable = false;
          pipewire = {
            enable = true;
            alsa.enable = true;
            # 32-bit ALSA is for Steam/Wine; a host that games turns it on.
            alsa.support32Bit = lib.mkDefault false;
            pulse.enable = true;
          };
        };
        security.rtkit.enable = true;

        # On at boot, so a bluetooth keyboard or mouse works at the login
        # screen.
        hardware.bluetooth = {
          enable = lib.mkDefault true;
          powerOnBoot = lib.mkDefault true;
        };

        fonts = {
          packages = with pkgs; [
            noto-fonts
            noto-fonts-color-emoji
            # Metric-compatible with Arial, Times New Roman and Courier New,
            # so documents from Windows users keep their layout.
            liberation_ttf
          ];
        };
      };
    };
}
