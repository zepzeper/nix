{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    go = lib.mkEnableOption "Go development";
  };

  config = lib.mkIf cfg.go {
    home.packages = with pkgs; [
      go
      gopls
      golangci-lint
      gotools
      delve
      go-tools
    ];

    home.sessionVariables = {
      GOPATH = "$HOME/go";
      GOBIN = "$HOME/go/bin";
    };

    home.sessionPath = [
      "$HOME/go/bin"
    ];
  };
}
