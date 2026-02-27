{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.lsp;
in {
  options.modules.development.lsp = {
    common = lib.mkEnableOption "Common LSPs for various file types";
  };

  config = lib.mkIf cfg.common {
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
