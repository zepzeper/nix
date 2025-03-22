{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "awesomepanda";
      plugins = ["git"];
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v.0.7.0";
          hash = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
    ];

    envExtra = ''
      ZSH_DISABLE_COMPFIX=true

      # NVM configuration
      export NVM_DIR="$HOME/.nvm"

      # LibTorch configuration
      export LIBTORCH=/usr/local/lib/libtorch
      export DYLD_LIBRARY_PATH=$LIBTORCH/lib:$DYLD_LIBRARY_PATH
      export LIBTORCH_USE_PYTORCH=1
      export LIBTORCH_BYPASS_VERSION_CHECK=1

      # PYENV configuration
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/bin:$PATH"

      # AVR GCC
      export PATH="/usr/local/opt/avr-gcc@13/bin:$PATH"

      # Go configuration
      export GOPATH=$HOME/go
      export PATH=$PATH:$GOPATH/bin

      # Custom scripts folder
      export PATH="$PATH:$HOME/scripts"

      # VIMRUNTIME
      VIMRUNTIME=$(dirname $(dirname $(readlink -f $(which nvim))))/share/nvim/runtime
    '';

    # Shell aliases from your .zshrc
    shellAliases = {
      # Dotfile management
      zshconf = "nvim ~/.dotfiles/.zshrc";
      ohmyzshconf = "nvim ~/.oh-my-zsh";
      tmuxconf = "nvim ~/.dotfiles/.tmux.conf";
      nvimconf = "nvim ~/.dotfiles/nvim";
      dot = "cd ~/.dotfiles";

      # Docker aliases
      dup = "docker compose up -d";
      down = "docker compose stop";
      dssh = "docker compose exec web bash";

      # Command replacements
      vim = "nvim";
      find = "fd";
      grep = "rg";
    };

    # Additional zsh initialization
    initExtra = ''
      # OPTIMIZATION: Lazy loading for NVM
      nvm() {
        unset -f nvm
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        nvm "$@"
      }

      # OPTIMIZATION: Lazy loading for pyenv
      pyenv() {
        unset -f pyenv
        eval "$(command pyenv init --path)"
        eval "$(command pyenv init -)"
        eval "$(command pyenv virtualenv-init -)"
        pyenv "$@"
      }

      # Key bindings
      bindkey '\t' autosuggest-accept

      # Case sensitive completion
      CASE_SENSITIVE="true"
    '';

  };
}
