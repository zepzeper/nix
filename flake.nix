{
  description = "zepzeper's NixOS configuration";

  # Inputs only. Everything else lives in ./modules and is picked up by
  # import-tree, so adding a file is all it takes to add a module.
  #
  # Rule: every input that has its own nixpkgs follows ours (one exception,
  # neovim-nightly, explained there), and an input is only added once
  # something uses it.
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

    # Secrets (secrets/): age-encrypted files, decrypted on each machine with
    # its SSH host key.
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure Boot (modules/boot/): lanzaboote signs the boot files with each
    # machine's own keys. Pinned to a release tag; a newer release is a new
    # tag here. Its tool is built from source (there is no binary cache),
    # once per nixpkgs update, on stable for every machine.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
      # Only used by lanzaboote's own development.
      inputs.pre-commit.follows = "";
    };

    # Helium, the browser (not in nixpkgs). Only its package recipe is used,
    # built with the host's own nixpkgs; `nix flake update helium` pulls a
    # new Helium release.
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Spicetify: a themed Spotify (modules/apps/spotify.nix).
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Neovim nightly, built from Neovim's main branch (nix-community keeps
    # this updated daily; `nix flake update neovim-nightly` moves to the
    # newest). The one input that keeps its own nixpkgs, on purpose: then
    # the build matches nix-community's binary cache (added on machines with
    # Neovim) and an update downloads Neovim instead of compiling it and
    # tree-sitter from source.
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
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
