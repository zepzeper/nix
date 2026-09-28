{
  # Printing and scanning. Network printers and scanners are found by
  # themselves (mDNS through Avahi, and driverless IPP/eSCL, which almost
  # every printer from the last decade speaks), so nothing is installed per
  # printer; USB ones work the same way through ipp-usb. Admins and people
  # can print and scan without sudo.
  flake.modules.nixos.services-printing =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      users = config.zep.users.options;
    in
    {
      key = "zep#services-printing";
      options.zep.printing.enable = lib.mkEnableOption "printing and scanning";

      config = lib.mkIf config.zep.printing.enable {
        services = {
          printing.enable = true;
          avahi = {
            enable = true;
            nssmdns4 = true;
            openFirewall = true;
          };
          ipp-usb.enable = true;
        };

        hardware.sane = {
          enable = true;
          extraBackends = [ pkgs.sane-airscan ];
        };

        users.users = lib.mapAttrs (_: _: {
          extraGroups = [
            "scanner"
            "lp"
          ];
        }) (users.admins // users.people);
      };
    };
}
