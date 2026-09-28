{
  # Networking, in one of two modes:
  #
  #   networkmanager - desktops and laptops: WiFi, VPNs, a GUI to switch.
  #   networkd       - servers: systemd-networkd, DHCP on every wired port
  #                    through nixpkgs' own 99-ethernet-default-dhcp. A host
  #                    with a static address or a bridge adds its own
  #                    systemd.network.networks."10-..." entry, which wins
  #                    because networkd uses the first match by name.
  flake.modules.nixos.networking =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zep.networking;
    in
    {
      key = "zep#networking";
      options.zep.networking = {
        enable = lib.mkEnableOption "networking";

        options.mode = lib.mkOption {
          type = lib.types.enum [
            "networkmanager"
            "networkd"
          ];
          default = "networkmanager";
        };

        # A VPN profile (an .ovpn file, or certificates) can then be
        # imported in the network settings, or with
        # `nmcli connection import type openvpn file <profile>.ovpn`.
        options.openvpn = lib.mkEnableOption "OpenVPN profiles in NetworkManager";
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.mkIf (cfg.options.mode == "networkmanager") {
            networking.networkmanager = {
              enable = true;
              plugins = lib.optional cfg.options.openvpn pkgs.networkmanager-openvpn;
            };
            # Admins and people can manage connections without sudo.
            users.users = lib.mkIf config.zep.users.enable (
              lib.mapAttrs (_: _: { extraGroups = [ "networkmanager" ]; }) (
                config.zep.users.options.admins // config.zep.users.options.people
              )
            );
          })
          (lib.mkIf (cfg.options.mode == "networkd") {
            networking.useNetworkd = true;
          })
        ]
      );
    };
}
