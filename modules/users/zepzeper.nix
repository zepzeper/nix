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
  };
}
