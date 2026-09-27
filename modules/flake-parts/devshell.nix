{
  # `nix develop` gives the tools to work on this repository.
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nh # nh os switch . - build, show the diff, switch
          nvd # compare two generations
          nix-tree # see what is in a closure
        ];
      };
    };
}
