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

  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.5.7"
  ];

  config = lib.mkIf cfg.database {
    home.packages = with pkgs; [
      beekeeper-studio
    ];
  };
}
