{ config, lib, pkgs, ... }:
let
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
      nodePackages.vscode-json-languageserver
      marksman
      nodePackages.markdownlint-cli
      nodePackages.dockerfile-language-server-nodejs
      hadolint
      sqls
      lemminx
      terraform-ls
      ansible-language-server
      nodePackages.graphql-language-service-cli
    ];
  };
}
