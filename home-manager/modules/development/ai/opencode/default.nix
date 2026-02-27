{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.ai;
in {
  options.modules.development.ai = {
    opencode = lib.mkEnableOption "Opencode terminal tools";
  };

  config = lib.mkIf cfg.opencode {
    home.packages = with pkgs; [
      opencode
    ];
  };
}
