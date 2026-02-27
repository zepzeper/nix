{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    haskell = lib.mkEnableOption "Haskell development";
  };

  config = lib.mkIf cfg.haskell {
    home.packages = with pkgs; [
      haskellPackages.ghc
      haskellPackages.cabal-install
      haskellPackages.stack
      haskellPackages.haskell-language-server
    ];
  };
}
