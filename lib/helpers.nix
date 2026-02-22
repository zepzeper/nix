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
    role ? "workstation", # workstation, minimal, or custom
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
      modules = [../home-manager];
    };

  # Helper for workstation/desktop machines with full desktop environment
  mkWorkstation = {
    hostname,
    username,
    platform,
    extraModules ? [], # Additional host-specific modules
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
      modules =
        [
          ../roles/workstation
        ]
        ++ extraModules
        ++ [
          ../hosts/${hostname}
        ];
    };

  # Helper for servers - minimal config, no GUI
  mkServer = {
    hostname,
    username,
    platform,
    extraModules ? [], # Additional host-specific modules
    isMasterNode,
    isWorkerNode,
  }: let
    isVM = false;
    isMaster = isMasterNode;
    isWorker = isWorkerNode;
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
          isMaster
          isWorker
          ;
      };
      modules =
        [
          ../roles/server
        ]
        ++ extraModules
        ++ lib.optionals isMaster [
          ../roles/k3s/k3s-master.nix
        ]
        ++ lib.optionals isWorker [
          ../roles/k3s/k3s-worker.nix
        ]
        ++ [
          ../hosts/${hostname}
        ];
    };

  # Helper for minimal headless systems
  mkMinimal = {
    hostname,
    username,
    platform,
    extraModules ? [],
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
      modules =
        [
          ../roles/minimal
        ]
        ++ extraModules
        ++ [
          ../hosts/${hostname}
        ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
