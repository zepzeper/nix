{
  config,
  lib,
  pkgs,
  ...
}: let
    cfg = config.apps;
in {
    options.apps = {
        steam = lib.mkEnableOption "Steam for gaming";
    };

    config = lib.mkIf cfg.steam {
        # ===== GAMING CONFIGURATION =====
        programs.steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
            gamescopeSession.enable = true;
            extraCompatPackages = with pkgs; [
                proton-ge-bin # Better compatibility than default Proton
            ];
        };

        # GameMode for better gaming performance
        programs.gamemode.enable = true;

        # Enable 32-bit libraries for gaming
        hardware.graphics.enable32Bit = true;

    };
}
