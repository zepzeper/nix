{
  inputs,
  outputs,
  stateVersion,
  lib,
  ...
}: {
  # Helper function for generating home-manager configs
  mkHome = {
    hostname,
    username,
    platform,
    role ? "workstation",
    extraHomeModules ? [],
  }: let
    isNixOS = true;
  in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          hostname
          platform
          username
          stateVersion
          isNixOS
          role
          ;
      };
      modules =
        [
          ../home-manager
        ]
        ++ extraHomeModules;
    };

  # Helper for machines
  mkMachine = {
    hostname,
    username,
    platform,
    roleSettings ? [],
    serviceSettings ? [],
  }: let
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          hostname
          platform
          username
          stateVersion
          ;
      };
      modules =
        [
          ../roles/default.nix
          ../modules/nixos/default.nix
          ../hosts/${hostname}
        ]
        ++ roleSettings
        ++ serviceSettings;
    };
}
