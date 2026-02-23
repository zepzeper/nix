{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
    cfg = config.apps.browser;
in {

  options.apps.browser = {
   helium = lib.mkEnableOption "Helium browser"; 
  };

  config = lib.mkIf cfg.helium {
      environment.systemPackages = with pkgs; [
        nur.repos.forkprince.helium-nightly
      ];
  };

}
