{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    tmux
  ];

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      resurrect
      continuum
    ];

    extraConfig = ''
      set-option -g default-shell /run/current-system/sw/bin/zsh
      # Terminal overrides for color support
      set -ag terminal-overrides ",alacritty:RGB"
      set -ag terminal-overrides ",*:Tc"
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      set-option -g window-status-current-format " #I:#W"
      set-option -g window-status-format " #I:#W"
      set-option -g window-status-current-style "fg=#CCFF0B,bold"
      set-option -g window-status-style "fg=grey"

      set-option -g status-position top
      set-option -g status-bg default
      set-option -g status-style bg=default
      set-option -g status-left ""
      set-option -g status-right "#{session_name} "
      set-option -g base-index 1

      set -g history-limit 50000
      set -g display-time 4000
      set -g status-interval 5
      set -g status-keys emacs
      set -g focus-events on
      set -g aggressive-resize on

      # Pane base index and renumbering
      set -g pane-base-index 1
      set-option renumber-windows on

      # Focus events
      set-option -g focus-events on

      # Key bindings for pane navigation
      bind -r j select-pane -d
      bind -r k select-pane -u
      bind -r l select-pane -r
      bind -r h select-pane -l

      # Window/pane creation
      bind -r o new-window -c '#{pane_current_path}'
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Custom script bindings
      bind-key f new-window "${config.home.homeDirectory}/scripts/tmux-sessionizer.sh"
      bind-key g new-window "${config.home.homeDirectory}/scripts/nix-devonizer.sh"
      bind-key i new-window "${config.home.homeDirectory}/scripts/cheat.sh"
      bind-key u new-window "${config.home.homeDirectory}/scripts/snipster.sh"

      # Copy mode settings
      bind e copy-mode
      bind-key -T copy-mode-vi y send-keys -X copy-pipe "pbcopy"
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi w send-keys -X select-word
    '';
  };

  programs.zsh = {
    shellAliases = {
      ta = "tmux attach-session -t";
      ts = "tmux new-session -s";

    };
  };

  # Ensure your custom scripts are available
  home.file = {
    "scripts/tmux-sessionizer.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/tmux-sessionizer.sh";
      executable = true;
    };

    "scripts/nix-devonizer.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/nix-devonizer.sh";
      executable = true;
    };

    "scripts/snipster.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/snipster.sh";
      executable = true;
    };

    "scripts/cheat.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/cheat.sh";
      executable = true;
    };
  };
}
