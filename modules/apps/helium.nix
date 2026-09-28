{ inputs, ... }:
{
  # Helium, a Chromium-based browser without Google's accounts, telemetry or
  # ads (uBlock Origin built in). Not in nixpkgs: the package recipe comes
  # from the `helium` flake input (a repackaged upstream release) and is
  # built with this machine's nixpkgs.
  #
  # Also the default browser: links from other apps open in it.
  flake.modules.nixos.apps-helium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zep.helium;
      helium = pkgs.callPackage "${inputs.helium}/helium.nix" { };
    in
    {
      key = "zep#apps-helium";
      options.zep.helium.enable = lib.mkEnableOption "the Helium browser, as the default browser";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ helium ];

        xdg.mime.defaultApplications = lib.genAttrs [
          "text/html"
          "application/xhtml+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ] (_: "helium.desktop");
      };
    };
}
