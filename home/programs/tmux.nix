{ config, pkgs, lib, ... }:

{
    programs.tmux = {
        enable = true;
        shortcut = "a";
        keyMode = "vi";
        escapeTime = 0;
        baseIndex = 1;
        historyLimit = 5000;
        mouse = true;
        terminal = "tmux-256color";

        extraConfig = ''
      # Terminal overrides for color support
      set -ag terminal-overrides ",alacritty:RGB"
      set -ag terminal-overrides ",*:Tc"

      # Pane base index and renumbering
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

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
      bind-key f new-window "${config.home.homeDirectory}/scripts/tmux-sessionizer"
      bind-key i new-window "${config.home.homeDirectory}/scripts/cheat.sh"
      bind-key b run-shell "$config.home.homeDirectory/scripts/wallpaper.sh > /dev/null"
      bind-key v new-window "${config.home.homeDirectory}/scripts/fivex-vpn.sh"

      # Copy mode settings
      bind e copy-mode
      bind-key -T copy-mode-vi y send-keys -X copy-pipe "pbcopy"
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi w send-keys -X select-word
        '';

        plugins = with pkgs.tmuxPlugins; [
            {
                plugin = resurrect;
                extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
                '';
            }
            {
                plugin = continuum;
                extraConfig = ''
          set -g @continuum-restore 'on'
                '';
            }
            vim-tmux-navigator  # For vim-tmux integration
            yank                # Better copy-paste integration
        ];

        # For macOS, you might need to install reattach-to-user-namespace
        # This is needed for clipboard integration with pbcopy
        secureSocket = pkgs.stdenv.isDarwin;

    };

    # Ensure your custom scripts are available
    home.file = {
        "scripts/tmux-sessionizer" = {
            source = "${config.home.homeDirectory}/.dotfiles/scripts/tmux-sessionizer";
            executable = true;
        };

        "scripts/cheat.sh" = {
            source = "${config.home.homeDirectory}/.dotfiles/scripts/cheat.sh";
            executable = true;
        };

        "scripts/wallpaper.sh" = {
            source = "${config.home.homeDirectory}/.dotfiles/scripts/wallpaper.sh";
            executable = true;
        };

        "scripts/fivex-vpn.sh" = {
            source = "${config.home.homeDirectory}/.dotfiles/scripts/fivex-vpn.sh";
            executable = true;
        };
    };
}
