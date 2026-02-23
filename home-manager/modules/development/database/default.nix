{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.database;
in {
  options.modules.development.database = {
    enable = lib.mkEnableOption "database tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      beekeeper-studio
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "beekeeper-studio-5.5.5"
    ];
  };
}
