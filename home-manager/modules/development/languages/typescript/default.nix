{ config, lib, pkgs, ... }:
let
  cfg = config.modules.development.languages.typescript;
in {
  options.modules.development.languages.typescript = {
    enable = lib.mkEnableOption "TypeScript/JavaScript development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_22
      nodePackages.npm
      nodePackages.pnpm
      nodePackages.yarn
      bun
      nodePackages.typescript
      nodePackages.typescript-language-server
      vscode-langservers-extracted
      nodePackages."@tailwindcss/language-server"
      nodePackages.vscode-json-languageserver
      nodePackages.prettier
      prettierd
      nodePackages.eslint
      nodePackages.vite
    ];
    
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
    
    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];
  };
}
