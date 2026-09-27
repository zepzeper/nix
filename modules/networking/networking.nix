{
  # Networking, in one of two modes:
  #
  #   networkmanager - desktops and laptops: WiFi, VPNs, a GUI to switch.
  #   networkd       - servers: systemd-networkd, DHCP on every wired port.
  #                    A host with a static address adds its own
  #                    systemd.network.networks entry.
  flake.modules.nixos.networking =
    { config, lib, ... }:
    let
      cfg = config.zep.networking;
    in
    {
      options.zep.networking = {
        enable = lib.mkEnableOption "networking";

        options.mode = lib.mkOption {
          type = lib.types.enum [
            "networkmanager"
            "networkd"
          ];
          default = "networkmanager";
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.mkIf (cfg.options.mode == "networkmanager") {
            networking.networkmanager.enable = true;
            # Admins and people can manage connections without sudo.
            users.users = lib.mapAttrs (_: _: { extraGroups = [ "networkmanager" ]; }) (
              config.zep.users.options.admins // config.zep.users.options.people
            );
          })
          (lib.mkIf (cfg.options.mode == "networkd") {
            networking.useNetworkd = true;
            systemd.network = {
              enable = true;
              networks."10-wired" = {
                matchConfig.Name = "en* eth*";
                networkConfig.DHCP = lib.mkDefault "yes";
              };
            };
          })
        ]
      );
    };
}
