{
  # Me, the same on every machine that has me as a Home Manager user. My
  # dotfiles sit next to this file. A host imports this for zepzeper:
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

    # tmux-sessionizer (Ctrl+F): which folders it offers, and what every new
    # session starts with. Both are plain files next to this one.
    xdg.configFile."tmux-sessionizer/tmux-sessionizer.conf".source = ./tmux-sessionizer.conf;
    home.file.".tmux-sessionizer".source = ./.tmux-sessionizer;

    # My Neovim config: cloned to ~/personal/nvim and linked to
    # ~/.config/nvim on machines with Neovim (modules/development/neovim.nix).
    zep.neovim.configRepo = "zepzeper/nvim";
  };
}
