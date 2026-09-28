{
  description = "zepzeper's NixOS configuration";

  # Inputs only. Everything else lives in ./modules and is picked up by
  # import-tree, so adding a file is all it takes to add a module.
  #
  # Rule: every input that has its own nixpkgs follows ours, and an input is
  # only added once something uses it.
  inputs = {
    # Two channels. Stable is the default and what employee laptops and
    # servers must run; unstable is for my own machines. A host picks one
    # with zep.hosts.<name>.channel (modules/flake-parts/host-machines.nix).
    #
    # When a new release comes out, bump nixpkgs and home-manager together:
    # their branches have to match.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Helium, the browser (not in nixpkgs). Only its package recipe is used,
    # built with the host's own nixpkgs; `nix flake update helium` pulls a
    # new Helium release.
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Neovim nightly, built from Neovim's main branch (nix-community keeps
    # this updated daily). `nix flake update neovim-nightly` moves to the
    # newest nightly; built against our nixpkgs, so an update compiles
    # Neovim once (a few minutes).
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-parts.follows = "flake-parts";
    };

    # ThePrimeagen's tmux-sessionizer, a single script (not in nixpkgs; the
    # nixpkgs "tmux-sessionizer" is a different program).
    tmux-sessionizer = {
      url = "github:ThePrimeagen/tmux-sessionizer";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
