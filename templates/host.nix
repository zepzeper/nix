# Template for a host. Copy to modules/hosts/<clients|servers>/<name>.nix.
#
# The name after "hosts/" becomes nixosConfigurations.<name> and the default
# hostname. Put the machine's generated hardware configuration next to it as
# _<name>-hardware.nix: files and folders starting with "_" are skipped by
# import-tree, so it is only imported here.
{ config, ... }:
{
  flake.modules.nixos."hosts/example" = {
    imports = with config.flake.modules.nixos; [
      profiles-base
      # ./_example-hardware.nix
    ];

    nixpkgs.hostPlatform = "x86_64-linux"; # "aarch64-linux" for the pi / laptop
    system.stateVersion = "26.05"; # set once at install, never change

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    users.users.zepzeper = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    home-manager.users.zepzeper = {
      home.stateVersion = "26.05";
    };

    # Blocks this machine turns on:
    #   zep.example.enable = true;
  };
}
