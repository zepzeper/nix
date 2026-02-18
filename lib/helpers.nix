{
  inputs,
  outputs,
  stateVersion,
  ...
}: {
  # Helper function for generating home-manager configs
  mkHome = {
    hostname,
    username,
    platform,
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
          ;
      };
      modules = [../home-manager];
    };

  # Helper for desktop machines with full desktop environment
  mkNixOS = {
    hostname,
    username,
    platform,
  }: let
    isVM = false;
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
          isVM
          ;
      };
      modules = [../hosts/${hostname}];
    };

  # Helper for servers - minimal config, no GUI, no home-manager
  mkServer = {
    hostname,
    username,
    platform,
  }: let
    isVM = false;
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
          isVM
          ;
      };
      modules = [../hosts/${hostname}];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
