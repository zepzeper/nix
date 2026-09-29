{
  description = "PHP 8.5 with Composer";

  # The development shell: `nix develop`, or automatically on `cd` with
  # direnv (the .envrc next to this file; `direnv allow` once). Pinned in
  # flake.lock, which belongs in git; `nix flake update` for newer tools.
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            php85
            php85.packages.composer
          ];
        };
      });
    };
}
