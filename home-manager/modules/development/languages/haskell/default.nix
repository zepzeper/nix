{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages.haskell;
in {
  options.modules.development.languages.haskell = {
    enable = lib.mkEnableOption "Haskell development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      haskellPackages.ghc
      haskellPackages.cabal-install
      haskellPackages.stack
      haskellPackages.haskell-language-server
    ];
  };
}
