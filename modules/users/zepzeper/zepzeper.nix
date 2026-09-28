{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
  secret = name: ../../../secrets + "/${name}.age";
in
{
  # Me, the same on every machine I use. My dotfiles sit next to this file. A
  # host imports the system half, which brings the Home Manager half along:
  #
  #   imports = [ config.flake.modules.nixos."users/zepzeper" ];
  #
  # Not blocks: never handed to other machines or users.

  # System half: my Home Manager setup, and my secrets on this machine (each
  # only once its .age file exists, see secrets/README.md).
  flake.modules.nixos."users/zepzeper" =
    { config, lib, ... }:
    let
      home = config.users.users.zepzeper.home;
      has = name: builtins.pathExists (secret name);
    in
    {
      key = "zep#users-zepzeper";

      home-manager.users.zepzeper.imports = [ homeManager."users/zepzeper" ];

      age.secrets = {
        # Read by the PHP language server in my Neovim config.
        intelephense = lib.mkIf (has "intelephense") {
          file = secret "intelephense";
          path = "${home}/intelephense/license.txt";
          owner = "zepzeper";
        };
        ansible-vault = lib.mkIf (has "ansible-vault") {
          file = secret "ansible-vault";
          owner = "zepzeper";
        };
      };

      # agenix creates ~/intelephense as root; hand it to me.
      systemd.tmpfiles.rules = lib.mkIf (has "intelephense") [
        "d ${home}/intelephense 0700 zepzeper users -"
      ];

      environment.variables.ANSIBLE_VAULT_PASSWORD_FILE = lib.mkIf (has "ansible-vault") config.age.secrets.ansible-vault.path;
    };

  # Home Manager half.
  flake.modules.homeManager."users/zepzeper" = {
    key = "zep#hm-users-zepzeper";

    home = {
      # Where Go, Cargo and my own scripts put programs, as in zepzeper/dev.
      sessionVariables.GOPATH = "$HOME/.local/go";
      sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.local/go/bin"
        "$HOME/.cargo/bin"
      ];

      # tmux-sessionizer: what every new session starts with (a file next to
      # this one).
      file.".tmux-sessionizer".source = ./.tmux-sessionizer;
    };

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

    # tmux-sessionizer (Ctrl+F): which folders it offers (a file next to this
    # one).
    xdg.configFile."tmux-sessionizer/tmux-sessionizer.conf".source = ./tmux-sessionizer.conf;

    # My Neovim config: cloned to ~/personal/nvim and linked to
    # ~/.config/nvim on machines with Neovim (modules/development/neovim.nix).
    zep.neovim.configRepo = "zepzeper/nvim";
  };
}
