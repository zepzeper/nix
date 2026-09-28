{ inputs, ... }:
{
  # tmux on every machine, with ThePrimeagen's tmux-sessionizer. Ported from
  # zepzeper/dev:
  #
  # - prefix Ctrl+A (Ctrl+A Ctrl+A sends a literal Ctrl+A), windows count
  #   from 1, vi keys in copy mode (v selects, y copies);
  # - prefix f: tmux-sessionizer, prefix o: new window in the same folder,
  #   prefix e: copy mode, prefix i: cheat sheet (cht.sh), prefix r: reload;
  # - Ctrl+F in zsh: tmux-sessionizer.
  #
  # Copying goes to the system clipboard through the terminal (OSC 52), so
  # it works the same on the desktop and in tmux on a server over SSH.
  #
  # Which folders the sessionizer offers is a personal setting:
  # ~/.config/tmux-sessionizer/tmux-sessionizer.conf (see modules/users).
  flake.modules.nixos.shell-tmux =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      tmux-sessionizer =
        pkgs.runCommand "tmux-sessionizer" { nativeBuildInputs = [ pkgs.makeWrapper ]; }
          ''
            install -Dm755 ${inputs.tmux-sessionizer}/tmux-sessionizer $out/bin/tmux-sessionizer
            wrapProgram $out/bin/tmux-sessionizer --prefix PATH : ${
              lib.makeBinPath [
                config.programs.tmux.package
                pkgs.fzf
                pkgs.findutils
                pkgs.coreutils
                pkgs.gnugrep
                pkgs.procps
              ]
            }
          '';

      # Pick a language or command, type a question, read the answer from
      # cht.sh in a new window. PHP goes to php.net, which covers it better.
      curl = lib.getExe pkgs.curl;
      w3m = lib.getExe pkgs.w3m;
      less = lib.getExe pkgs.less;
      cheat = pkgs.writeShellApplication {
        name = "cheat";
        runtimeInputs = [
          pkgs.fzf
          pkgs.gnugrep
          config.programs.tmux.package
        ];
        text = ''
          languages=${./cht-languages}
          selected=$(cat "$languages" ${./cht-commands} | fzf) || exit 0
          read -rp "Enter query: " query
          query=''${query// /+}

          # The new window runs in tmux's environment, not this script's:
          # full paths.
          if [[ $selected == php ]]; then
            tmux neww bash -c "${curl} -sL 'https://www.php.net/$query' | ${w3m} -dump -T text/html | ${less}"
          elif grep -qx "$selected" "$languages"; then
            tmux neww bash -c "${curl} -s 'cht.sh/$selected/$query' | ${less} -R"
          else
            tmux neww bash -c "${curl} -s 'cht.sh/$selected~$query' | ${less} -R"
          fi
        '';
      };
    in
    {
      key = "zep#shell-tmux";
      options.zep.tmux.enable = lib.mkEnableOption "tmux with tmux-sessionizer";

      config = lib.mkIf config.zep.tmux.enable {
        programs.tmux = {
          enable = true;
          terminal = "tmux-256color";
          escapeTime = 0;
          baseIndex = 1;
          clock24 = true;
          extraConfig = ''
            unbind C-b
            set -g prefix C-a
            bind C-a send-prefix

            set -g status-style 'bg=#333333 fg=#5eacd3'

            # Copy mode: v selects, y copies to the system clipboard (OSC 52).
            set -g mode-keys vi
            set -s set-clipboard on
            bind e copy-mode
            bind -T copy-mode-vi v send-keys -X begin-selection
            bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

            bind r source-file /etc/tmux.conf \; display-message "tmux config reloaded"
            bind -r o new-window -c '#{pane_current_path}'

            bind f new-window tmux-sessionizer
            bind i popup -E cheat
          '';
        };

        environment.systemPackages = [
          tmux-sessionizer
          cheat
        ];

        programs.zsh.interactiveShellInit = lib.mkIf config.zep.zsh.enable ''
          bindkey -s '^f' "tmux-sessionizer\n"
        '';
      };
    };
}
