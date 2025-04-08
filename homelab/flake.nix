{
  description = "Raspberry Pi Cluster NixOS Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # Disko for disk management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, disko, ... }@inputs: let
    nodes = [
      "pi-master"  # First node
      # "pi-node-1"  # Uncomment as you add more nodes
      # "pi-node-2"
    ];
  in {
    nixosConfigurations = builtins.listToAttrs (map (name: {
      name = name;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          meta = { 
            hostname = name;
            isMaster = (name == "pi-master");
          };
        };
        system = "aarch64-linux";  # Correct architecture for Raspberry Pi
        modules = [
          # Modules
          disko.nixosModules.disko
          ./hardware-configuration.nix
          ./configuration.nix
          ./k3s-config.nix
        ];
      };
    }) nodes);
  };
}
