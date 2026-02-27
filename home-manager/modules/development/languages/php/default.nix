{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    php = lib.mkEnableOption "PHP development";
  };

  config = lib.mkIf cfg.php {
    home.packages = with pkgs; [
      php84
      php84Packages.composer
      phpactor
      php84Packages.php-cs-fixer
      php84Extensions.xdebug
    ];
  };
}
