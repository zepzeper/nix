{
  # Time zone, language and keyboard. The desktop language and the regional
  # formats (dates, numbers, currency, paper) are separate settings, so an
  # English desktop can still use Dutch formats.
  flake.modules.nixos.base-locale =
    { config, lib, ... }:
    let
      cfg = config.zep.locale;
    in
    {
      key = "zep#base-locale";
      options.zep.locale = {
        enable = lib.mkEnableOption "time zone, language and keyboard";

        options = {
          timeZone = lib.mkOption {
            type = lib.types.str;
            default = "Europe/Amsterdam";
          };
          language = lib.mkOption {
            type = lib.types.str;
            default = "en_US.UTF-8";
            description = "Language of the system and desktop.";
          };
          formats = lib.mkOption {
            type = lib.types.str;
            default = "nl_NL.UTF-8";
            description = "Locale for dates, numbers, currency, paper size and measurements.";
          };
          keyboardLayout = lib.mkOption {
            type = lib.types.str;
            default = "us";
          };
          keyboardVariant = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "intl";
            description = ''
              e.g. "intl" or "altgr-intl" for accents (é, ë) on a US keyboard.
              Also the layout of the disk passphrase prompt at boot.
            '';
          };
        };
      };

      config = lib.mkIf cfg.enable {
        time.timeZone = lib.mkDefault cfg.options.timeZone;

        i18n = {
          defaultLocale = cfg.options.language;
          extraLocaleSettings = lib.genAttrs [
            "LC_ADDRESS"
            "LC_IDENTIFICATION"
            "LC_MEASUREMENT"
            "LC_MONETARY"
            "LC_NAME"
            "LC_NUMERIC"
            "LC_PAPER"
            "LC_TELEPHONE"
            "LC_TIME"
          ] (_: cfg.options.formats);
        };

        console.useXkbConfig = true;
        services.xserver.xkb = {
          layout = lib.mkDefault cfg.options.keyboardLayout;
          variant = lib.mkDefault cfg.options.keyboardVariant;
        };
      };
    };
}
