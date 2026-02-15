{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages.php;
in {
  options.modules.development.languages.php = {
    enable = lib.mkEnableOption "PHP development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      php84
      php84Packages.composer
      phpactor
      php84Packages.php-cs-fixer
      php84Extensions.xdebug
    ];
  };
}
