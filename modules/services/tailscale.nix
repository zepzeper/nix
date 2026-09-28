{
  # Tailscale: the machine joins my tailnet, so my machines reach each other
  # (SSH, services) from anywhere without opening ports to the internet.
  #
  # Logging in: once per machine, `sudo tailscale up` and open the link it
  # prints. Or, with options.authKey, the machine logs itself in with the
  # auth key in secrets/tailscale-authkey.age (handy for servers). An auth key
  # is only used for that first login; once logged in the machine stays in.
  #
  # DNS goes through systemd-resolved, which NetworkManager and Tailscale
  # both work with, so MagicDNS names (`ssh <machine>`) resolve without the
  # two fighting over /etc/resolv.conf.
  flake.modules.nixos.services-tailscale =
    { config, lib, ... }:
    let
      cfg = config.zep.tailscale;
      authKeyFile = ../../secrets/tailscale-authkey.age;
      useAuthKey = cfg.options.authKey && builtins.pathExists authKeyFile;
    in
    {
      key = "zep#services-tailscale";
      options.zep.tailscale = {
        enable = lib.mkEnableOption "Tailscale";

        options.authKey = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Log in with the auth key in secrets/tailscale-authkey.age (once it has been added).";
        };
      };

      config = lib.mkIf cfg.enable {
        services.tailscale = {
          enable = true;
          # The UDP port for direct connections between machines; without
          # it traffic falls back to Tailscale's relays.
          openFirewall = true;
          authKeyFile = lib.mkIf useAuthKey config.age.secrets.tailscale-authkey.path;
        };

        age.secrets.tailscale-authkey = lib.mkIf useAuthKey { file = authKeyFile; };

        services.resolved.enable = lib.mkDefault true;
      };
    };
}
