{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development;
in {
  options.modules.development = {
    kubernetes = lib.mkEnableOption "kubernetes tools";
  };

  config = lib.mkIf cfg.kubernetes {
    home.packages = with pkgs; [
      kubectl
      kubernetes-helm
      k9s
    ];
  };
}
