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
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.options.environment != null;
            message = ''zep.desktop is on but no desktop is chosen: set zep.desktop.options.environment to "niri", "plasma" or "gnome".'';
          }
        ];

        # Sound
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = lib.mkDefault true;
          pulse.enable = true;
        };

        hardware.bluetooth = {
          enable = lib.mkDefault true;
          powerOnBoot = lib.mkDefault false;
        };

        fonts = {
          enableDefaultPackages = true;
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
