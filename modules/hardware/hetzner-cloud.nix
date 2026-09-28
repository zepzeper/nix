{
  # A Hetzner Cloud server (x86 VM). What differs from a machine of our own:
  #
  # - The one disk is /dev/sda (virtio SCSI, no stable by-id name per model);
  #   the standard layout goes on it. New x86 VMs boot UEFI only, which the
  #   standard layout and systemd-boot already are.
  # - IPv4 comes from DHCP, but IPv6 does not: each server gets a /64, shown
  #   in the Cloud Console, and uses one address from it with fe80::1 as its
  #   gateway (options.ipv6).
  # - The QEMU guest drivers come with the hardware file nixos-anywhere
  #   generates (nixpkgs' qemu-guest profile).
  #
  # Installed from the desktop with nixos-anywhere, straight from the Ubuntu
  # image Hetzner starts the server with (see the README).
  flake.modules.nixos.hardware-hetzner-cloud =
    { config, lib, ... }:
    let
      cfg = config.zep.hetznerCloud;
    in
    {
      key = "zep#hardware-hetzner-cloud";
      options.zep.hetznerCloud = {
        enable = lib.mkEnableOption "a Hetzner Cloud server";

        options.ipv6 = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "2a01:4f8:c012:3456::1/64";
          description = ''
            The server's IPv6 address with its prefix: the /64 from the Cloud
            Console, with ::1 (or any address in it). Null: IPv4 only.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = config.zep.networking.options.mode == "networkd";
            message = "zep.hetznerCloud: its network setup is for systemd-networkd (the server profile's default).";
          }
        ];

        zep.disk.options.device = lib.mkDefault "/dev/sda";

        # The one network card: DHCP for IPv4, the fixed IPv6 address. Named
        # "10-..." so it wins over nixpkgs' catch-all DHCP.
        systemd.network.networks."10-hetzner" = {
          matchConfig.Type = "ether";
          networkConfig.DHCP = "ipv4";
          address = lib.optional (cfg.options.ipv6 != null) cfg.options.ipv6;
          routes = lib.optional (cfg.options.ipv6 != null) { Gateway = "fe80::1"; };
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };
}
