{
  # Steam, with what it needs around it: 32-bit graphics drivers (set by the
  # Steam module), controller support, and Proton for Windows games.
  flake.modules.nixos.apps-steam =
    { config, lib, ... }:
    {
      key = "zep#apps-steam";
      options.zep.steam.enable = lib.mkEnableOption "Steam";

      config = lib.mkIf config.zep.steam.enable {
        programs.steam.enable = true;
      };
    };
}
