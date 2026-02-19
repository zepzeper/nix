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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "github:hyprwm/Hyprland";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nur.url = "github:nix-community/NUR";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    stateVersion = "25.05";
    helper = import ./lib {inherit inputs outputs stateVersion;};
  in {
    # Home configurations
    homeConfigurations = {
      # Desktop workstation
      desktop = helper.mkHome {
        username = "zepzeper";
        hostname = "desktop";
        platform = "x86_64-linux";
        role = "workstation";
      };

      # Laptop
      laptop = helper.mkHome {
        username = "zepzeper";
        hostname = "laptop";
        platform = "x86_64-linux";
        role = "workstation";
      };
    };

    # NixOS configurations
    nixosConfigurations = {
      # Desktop workstation
      desktop = helper.mkWorkstation {
        username = "zepzeper";
        hostname = "desktop";
        platform = "x86_64-linux";
        extraModules = [
          # Desktop-specific hardware
          ./modules/nixos/features/desktop/graphics
          {modules.graphics.gpu = "nvidia";}
        ];
      };

      # Laptop
      laptop = helper.mkWorkstation {
        username = "zepzeper";
        hostname = "laptop";
        platform = "x86_64-linux";
        extraModules = [
        ];
      };

      # ds10u server
      ds10u = helper.mkServer {
        username = "admin";
        hostname = "ds10u";
        platform = "x86_64-linux";
      };
    };

    devShells = nixpkgs.lib.genAttrs ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = [
          inputs.home-manager.packages.${system}.home-manager
        ];
      };
    });
  };
}
