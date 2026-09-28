{
  # Me, the same on every machine that has me as a Home Manager user. My
  # dotfiles sit next to this file. A host imports this for zepzeper:
  #
  #   home-manager.users.zepzeper.imports =
  #     [ config.flake.modules.homeManager."users/zepzeper" ];
  #
  # Not a block: it is never handed to other users.
  flake.modules.homeManager."users/zepzeper" =
    {
      config,
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      nvimRepo = "${config.home.homeDirectory}/personal/nvim";
    in
    {
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

      # Neovim's config is its own repository, cloned to ~/personal/nvim and
      # linked to ~/.config/nvim, so it stays a normal git checkout: edit,
      # commit and push it there. Cloned on the first switch if it is missing
      # (over https, which needs no key; pushing goes over ssh). Without a
      # network the clone waits for the next switch; nothing else fails.
      # Only on machines with Neovim (zep.neovim).
      xdg.configFile.nvim = lib.mkIf osConfig.zep.neovim.enable {
        source = config.lib.file.mkOutOfStoreSymlink nvimRepo;
      };

      home.activation.cloneNvim = lib.mkIf osConfig.zep.neovim.enable (
        lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
          if [ ! -e "${nvimRepo}" ]; then
            run mkdir -p "$(dirname "${nvimRepo}")"
            if run ${lib.getExe pkgs.git} clone https://github.com/zepzeper/nvim "${nvimRepo}"; then
              run ${lib.getExe pkgs.git} -C "${nvimRepo}" remote set-url --push origin git@github.com:zepzeper/nvim.git
            else
              warnEcho "Could not clone zepzeper/nvim to ${nvimRepo}; it is tried again on the next switch."
            fi
          fi
        ''
      );
    };
}
