{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages.go;
in {
  options.modules.development.languages.go = {
    enable = lib.mkEnableOption "Go development";
  };

  config = lib.mkIf cfg.enable {
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
