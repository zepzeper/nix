{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.languages;
in {
  options.modules.development.languages = {
    typescript = lib.mkEnableOption "TypeScript/JavaScript development";
  };

  config = lib.mkIf cfg.typescript {
    home.packages = with pkgs; [
      nodePackages.npm
      nodePackages.pnpm
      nodePackages.yarn
      bun
      nodePackages.typescript
      nodePackages.typescript-language-server
      vscode-langservers-extracted
      nodePackages."@tailwindcss/language-server"
      nodePackages.prettier
      prettierd
      nodePackages.eslint
    ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };

    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];
  };
}
