{
  # Tailscale: the machine joins my tailnet, so my machines reach each other
  # (SSH, services) from anywhere without opening ports to the internet.
  #
  # Logging in: once per machine, `sudo tailscale up` and open the link it
  # prints. Or, with options.authKey, the machine logs itself in with the
  # auth key in secrets/tailscale-authkey.age (handy for servers). It then
  # uses the key whenever it is logged out, also after its login expires, so
  # the key has to stay valid (a reusable key; or switch key expiry off for
  # the machine in the admin console and the option off after the first
  # login). `tailscale` works without sudo for the (first) admin.
  #
  # SSH always answers over the tailnet, also on machines where it is closed
  # to the network they are on (laptops): so I reach every machine with my
  # key, through the tailnet only.
  #
  # DNS goes through systemd-resolved, which NetworkManager and Tailscale
  # both work with, so MagicDNS names (`ssh <machine>`) resolve without the
  # two fighting over /etc/resolv.conf.
  flake.modules.nixos.services-tailscale =
    {
      config,
      lib,
      secretFile,
      ...
    }:
    let
      cfg = config.zep.tailscale;
      authKeyFile = secretFile "tailscale-authkey";
      useAuthKey = cfg.options.authKey && authKeyFile != null;
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
          extraSetFlags = map (name: "--operator=${name}") (
            lib.take 1 (lib.attrNames config.zep.users.options.admins)
          );
        };

        age.secrets.tailscale-authkey = lib.mkIf useAuthKey { file = authKeyFile; };

        networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts =
          lib.mkIf config.services.openssh.enable config.services.openssh.ports;

        services.resolved.enable = lib.mkDefault true;
      };
    };
}
