{ config, ... }:
{
  # The base every machine imports. Two jobs:
  #
  # 1. Import every block, so each `zep.<block>.enable` option exists on every
  #    host. Importing does not turn anything on: blocks are off until a
  #    profile or a host enables them.
  # 2. Force on the few blocks every machine must have, with lib.mkForce, so a
  #    host cannot drop them by accident. Everything else uses lib.mkDefault
  #    or is left to the host.
  flake.modules.nixos.profiles-base =
    { lib, ... }:
    {
      imports = with config.flake.modules.nixos; [
        # Add blocks here as they are written, e.g.
        #   services-audio
        #   desktops-hyprland
      ];

      # Mandatory blocks go here, e.g.
      #   zep.ssh.enable = lib.mkForce true;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = lib.mkDefault true;
      };

      nixpkgs.config.allowUnfree = lib.mkDefault true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
}
