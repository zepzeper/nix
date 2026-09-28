{
  # LibreOffice (the "still" branch: the one meant for work), with Dutch and
  # English spelling and Dutch hyphenation. The Qt build on Plasma so it
  # looks native there, the GTK one elsewhere.
  flake.modules.nixos.apps-office =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      plasma = config.zep.desktop.enable && config.zep.desktop.options.environment == "plasma";
    in
    {
      key = "zep#apps-office";
      options.zep.office.enable = lib.mkEnableOption "LibreOffice with Dutch and English spelling";

      config = lib.mkIf config.zep.office.enable {
        environment.systemPackages = [
          (if plasma then pkgs.libreoffice-qt6-still else pkgs.libreoffice-still)
          pkgs.hunspellDicts.nl_nl
          pkgs.hunspellDicts.en_US
          pkgs.hyphenDicts.nl_NL
        ];
      };
    };
}
