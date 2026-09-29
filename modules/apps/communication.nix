{
  # Mail, calendar and chat for work: Thunderbird and the Mattermost desktop
  # app.
  flake.modules.nixos.apps-communication =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      key = "zep#apps-communication";
      options.zep.communication.enable = lib.mkEnableOption "Thunderbird and Mattermost";

      config = lib.mkIf config.zep.communication.enable {
        programs.thunderbird.enable = true;
        environment.systemPackages = [ pkgs.mattermost-desktop ];
      };
    };
}
