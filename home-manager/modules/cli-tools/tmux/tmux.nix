{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    tmux
  ];

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    baseIndex = 1;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      resurrect
      continuum
    ];

    extraConfig = ''
      set -sag terminal-features ",*:RGB"
      set -sag terminal-features ",*:usstyle"
      set-option -ga terminal-overrides ",*-256color*:TC"
			set-option -sg escape-time 10

      set -g prefix C-a
      unbind C-b
      bind-key C-a send-prefix

      unbind '"'
      unbind %
      unbind r

      # Window/pane creation
      unbind %
      bind | split-window -h -c "#{pane_current_path}"

      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"

      bind -r o new-window -c '#{pane_current_path}'

      bind - split-window -v -c "#{pane_current_path}"

      set -g mouse on

      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      set-window-option -g mode-keys vi

      # Copy mode settings
      bind e copy-mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
      bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"
      bind-key -T copy-mode-vi w send-keys -X select-word
      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse

			# ----- tpipeline configuration -----
      # Set the status bar at the bottom
      set -g status-position bottom

      # Set transparent background for tpipeline
      set -g status-bg default
      set -g status-style bg=default

      # Provide enough space for vim statusline
      set -g status-left-length 90
      set -g status-right-length 90

      # Configure the tmux status line for tpipeline compatibility
      set -g status-justify absolute-centre

      set -g status-left ""
      set -g status-right ""

      # Configure status elements - simpler format with only window numbers
      set -g window-status-format " #I "
      set -g window-status-style "fg=#565f89,bg=default,dim"
      set -g window-status-last-style "fg=#565f89,bg=default"
      set -g window-status-activity-style "fg=#565f89,bg=default,dim"
      set -g window-status-bell-style "fg=#565f89,bg=default,dim"
      set -g window-status-separator "│"

      # Active window status format - highlight with green
      set -g window-status-current-format " #I "
      set -g window-status-current-style "fg=#9ece6a,bg=default,bold"

      # Pane border look and feel
      setw -g pane-border-status off
      setw -g pane-border-format ""
      setw -g pane-active-border-style "fg=#9ece6a"
      setw -g pane-border-style "fg=#565f89"
      setw -g pane-border-lines single

      set -g @resurrect-capture-pane-contents 'on' # allow tmux-ressurect to capture pane contents
      set -g @continuum-restore 'on' # enable tmux-continuum functionality

      # for image display
      set-option -g allow-passthrough on
      set -g visual-activity off

      # Custom script bindings
      bind-key f new-window "${config.home.homeDirectory}/scripts/tmux-sessionizer.sh"
      bind-key g new-window "${config.home.homeDirectory}/scripts/nix-devonizer.sh"
      bind-key i new-window "${config.home.homeDirectory}/scripts/cheat.sh"
      bind-key u new-window "${config.home.homeDirectory}/scripts/snipster.sh"
      bind-key r new-window "${config.home.homeDirectory}/scripts/rec.sh"

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
    "${config.home.homeDirectory}/scripts/tmux-sessionizer.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/tmux-sessionizer.sh";
      executable = true;
    };

    "${config.home.homeDirectory}/scripts/nix-devonizer.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/nix-devonizer.sh";
      executable = true;
    };

    "${config.home.homeDirectory}/scripts/snipster.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/snipster.sh";
      executable = true;
    };

    "${config.home.homeDirectory}/scripts/cheat.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/cheat.sh";
      executable = true;
    };
    "${config.home.homeDirectory}/scripts/rec.sh" = {
      source = "${config.home.homeDirectory}/.dotfiles/scripts/rec.sh";
      executable = true;
    };
  };
}
