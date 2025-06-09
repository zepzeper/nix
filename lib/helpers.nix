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
      username ? "zepzeper",
      platform ? "aarch64-darwin",
    }:
    let
      isDarwin = hostname == "m1-mbp";
			isNixOS = hostname == "nixix";

      nixvimSpecialArgs = {
        inputs = {
          nixpkgs = inputs.nixpkgs;
          nixvim = inputs.nixvim;
          blink-cmp = inputs.blink-cmp;
          self = inputs.my-nixvim-config;
        };
        self = inputs.my-nixvim-config;
      };

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
          isDarwin
	  isNixOS
          ;
        my-nixvim-config = inputs.my-nixvim-config;
        inherit nixvimSpecialArgs;
      };
      modules = [ ../home-manager ];
    };

  mkNixOS =
    {
      hostname,
      username ? "zepzeper",
      platform ? "x86_64-linux",
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

  mkDarwin =
    {
      hostname,
      username ? "zepzeper",
      platform ? "aarch64-darwin",
    }:
    let
      isVM = false;
    in
    inputs.nix-darwin.lib.darwinSystem {
			system = platform;
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
      modules = [ ../nix-darwin ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
