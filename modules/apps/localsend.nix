{
  # LocalSend: send files to phones and computers on the same network. Its
  # port is opened so other devices can send to this one.
  flake.modules.nixos.apps-localsend =
    { config, lib, ... }:
    {
      key = "zep#apps-localsend";
      options.zep.localsend.enable = lib.mkEnableOption "LocalSend";

      config = lib.mkIf config.zep.localsend.enable {
        programs.localsend = {
          enable = true;
          openFirewall = true;
        };
      };
    };
}
