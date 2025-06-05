{
  description = "Zepzeper's NixOS/Darwin Configuration";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Darwin-specific
    nix-darwin = {
	    url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
	    inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
	    url = "github:zhaofengli/nix-homebrew";
	    inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Hyprland
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, nix-darwin, nix-homebrew, home-manager, nixos-hardware, hyprland }:
  let
    # User configuration
    username = "zepzeper";
    
    # Helper function to create shared arguments
    mkSpecialArgs = hostname: system: {
      inherit inputs hostname system username;
      browser = "firefox";
      terminal = "alacritty";
    };
  in
  {
    # Darwin configurations
    darwinConfigurations = {
      "m1-pro" = nix-darwin.lib.darwinSystem {
        specialArgs = mkSpecialArgs "m1-pro" "aarch64-darwin";
        modules = [
          ./hosts/m1-pro/configuration.nix
	];
      };
    };

    # NixOS configurations
    nixosConfigurations = {
      "desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkSpecialArgs "desktop" "x86_64-linux";
        modules = [
          ./hosts/desktop/configuration.nix
        ];
      };
    };

    # Development shells
    devShells = {
      aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
        buildInputs = with nixpkgs.legacyPackages.aarch64-darwin; [
          nixpkgs-fmt
          statix
          deadnix
        ];
      };
      
      x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          nixpkgs-fmt
          statix
          deadnix
        ];
      };
    };

    # Formatters for both platforms
    formatter = {
      aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };

    # Templates for new configurations
    templates.default = {
      path = ./.;
      description = "Zepzeper's NixOS/Darwin flake template";
    };
  };
}
