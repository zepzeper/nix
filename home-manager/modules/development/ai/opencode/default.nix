{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.ai.opencode;
in {
  options.modules.development.ai.opencode = {
    enable = lib.mkEnableOption "Opencode terminal tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      opencode
    ];
  };
}
