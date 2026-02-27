{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development;
in {
  options.modules.development = {
    database = lib.mkEnableOption "database tools";
  };

  config = lib.mkIf cfg.database {
    home.packages = with pkgs; [
      beekeeper-studio
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "beekeeper-studio-5.5.5"
    ];
  };
}
