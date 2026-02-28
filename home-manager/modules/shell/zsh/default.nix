{
  config,
  lib,
  pkgs,
  role,
  ...
}: let
  cfg = config.modules.shell;
  
  # Define prompt color based on role
  promptColor = if role == "workstation" then "green" else "red";
in {
  options.modules.shell = {
    zsh = lib.mkEnableOption "zsh configuration";
    role = lib.mkOption {
      type = lib.types.str;
      default = "server";
      description = "System role (workstation or server)";
    };
  };
  config = lib.mkIf cfg.zsh {
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      shellAliases = {
        cat = "bat --paging=never";
      };
      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];
      initContent = ''
        bindkey -s '^f' "$HOME/.local/bin/tmux-sessionizer\n"
        
        # Add hostname to prompt with color
        PROMPT="%F{${promptColor}}[%m]%f $PROMPT"
      '';
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "fzf"
          "docker"
          "sudo"
        ];
      };
    };
  };
}
