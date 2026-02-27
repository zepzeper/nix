{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    rust = lib.mkEnableOption "Rust development";
  };

  config = lib.mkIf cfg.rust {
    home.packages = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      cargo-watch
      cargo-edit
      cargo-outdated
    ];

    home.sessionVariables = {
      RUST_BACKTRACE = "1";
    };
  };
}
