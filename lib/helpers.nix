{
  inputs,
  outputs,
  stateVersion,
  ...
}:
{
  # Helper function for generating home-manager configs
  mkHome =
    {
      hostname,
      username,
      platform,
    }:
    let
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
      modules = [ ../home-manager ];
    };

  mkNixOS =
    {
      hostname,
      username,
      platform,
    }:
    let
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
      modules = [ ../nixos ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
