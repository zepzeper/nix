{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.kubernetes;
in {
  options.modules.development.kubernetes = {
    enable = lib.mkEnableOption "kubernetes tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl
      kubernetes-helm
      k9s
    ];
  };
}
