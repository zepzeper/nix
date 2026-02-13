{
  description = "Zepzeper's NixOS & Home Manager Configuration";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blink-cmp = {
      url = "github:saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #  my-nixvim-config = {
    #    #url = "github:zepzeper/nixvim";
			 # url = "path:/home/zepzeper/.dotfiles/nixvim"; # local path for testing
    # 
    #    inputs.nixpkgs.follows = "nixpkgs";
    #    inputs.nixvim.follows = "nixvim";
    #    inputs.blink-cmp.follows = "blink-cmp";
    #  };

    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "github:hyprwm/Hyprland";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      stateVersion = "25.05";
      helper = import ./lib { inherit inputs outputs stateVersion; };

    in
    {
      homeConfigurations = {
        "zepzeper@nixix" = helper.mkHome {
          hostname = "nixix";
          platform = "x86_64-linux";
        };
      };

      nixosConfigurations = {
        nixix = helper.mkNixOS {
          hostname = "nixix";
          platform = "x86_64-linux";
        };
      };

	  devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
			  let
			  pkgs = nixpkgs.legacyPackages.${system};
			  in
			  {
			  default = pkgs.mkShell {
			  packages = [
			  inputs.home-manager.packages.${system}.home-manager
			  pkgs.git
			  ];
			  };
			  });
	};
}
