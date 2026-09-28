{
  # Firefox, in Dutch and English, without telemetry.
  flake.modules.nixos.apps-firefox =
    { config, lib, ... }:
    {
      key = "zep#apps-firefox";
      options.zep.firefox.enable = lib.mkEnableOption "Firefox";

      config = lib.mkIf config.zep.firefox.enable {
        programs.firefox = {
          enable = true;
          languagePacks = [
            "nl"
            "en-US"
          ];
          policies = {
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
          };
        };
      };
    };
}
