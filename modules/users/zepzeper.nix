{
  # Me, the same on every machine that has me as a Home Manager user. A host
  # imports this for zepzeper:
  #
  #   home-manager.users.zepzeper.imports =
  #     [ config.flake.modules.homeManager."users/zepzeper" ];
  #
  # Not a block: it is never handed to other users.
  flake.modules.homeManager."users/zepzeper" = {
    key = "zep#users-zepzeper";

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "zepzeper";
          email = "woutervk98@proton.me";
        };
        init.defaultBranch = "main";
        # `git push` on a new branch creates it on the remote.
        push.autoSetupRemote = true;
      };
    };

    # tmux-sessionizer (Ctrl+F): the folders it offers, one level deep.
    # A folder that does not exist on a machine is skipped.
    xdg.configFile."tmux-sessionizer/tmux-sessionizer.conf".text = ''
      TS_SEARCH_PATHS=(~/personal:1 /data:1)
      TS_LOG=file
      # `tmux-sessionizer -s 0` opens this in a window of the current session.
      TS_SESSION_COMMANDS=("nvim .")
    '';

    # Run in every new session: a scratch window, and Neovim on the project.
    # A project can bring its own .tmux-sessionizer instead.
    home.file.".tmux-sessionizer".text = ''
      if [[ "$(pwd)" == $HOME/personal ]]; then
          clear
          return
      fi
      tmux new-window -dn scratch
      nvim .
      clear
    '';
  };
}
