{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.lsp.common;
in {
  options.modules.development.lsp.common = {
    enable = lib.mkEnableOption "Common LSPs for various file types";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodePackages.bash-language-server
      shellcheck
      shfmt
      yaml-language-server
      yamllint
      taplo
      marksman
      nodePackages.markdownlint-cli
      dockerfile-language-server
      hadolint
      sqls
      lemminx
      terraform-ls
      nodePackages.graphql-language-service-cli
    ];
  };
}
