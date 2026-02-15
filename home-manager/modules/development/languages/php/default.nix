{ config, lib, pkgs, ... }:
let
  cfg = config.modules.development.languages.php;
in {
  options.modules.development.languages.php = {
    enable = lib.mkEnableOption "PHP development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      php83
      php83Packages.composer
      nodePackages.intelephense
      php83Packages.php-cs-fixer
      php83Extensions.xdebug
    ];
  };
}
