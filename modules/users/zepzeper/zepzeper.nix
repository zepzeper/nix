{ config, lib, ... }:
let
  inherit (config.flake.modules) homeManager;

  # The SSH keys that may log in as me: one per machine I work from, in
  # authorized_keys next to this file (also used by the installer image).
  sshKeys = lib.filter (line: line != "" && !lib.hasPrefix "#" line) (
    lib.splitString "\n" (builtins.readFile ./authorized_keys)
  );
in
{
  # Me, the same on every machine I use. My dotfiles sit next to this file. A
  # host imports the system half, which brings the Home Manager half along:
  #
  #   imports = [ config.flake.modules.nixos."users/zepzeper" ];
  #
  # Not blocks: never handed to other machines or users.

  # System half: me as an admin (wheel, my SSH keys), my Home Manager setup,
  # and my secrets on this machine (each once it exists for this machine,
  # see secrets/README.md).
  flake.modules.nixos."users/zepzeper" =
    {
      config,
      lib,
      secretFile,
      ...
    }:
    let
      mine = file: {
        inherit file;
        owner = "zepzeper";
      };
      intelephense = secretFile "intelephense";
      ansibleVault = secretFile "ansible-vault";
    in
    {
      key = "zep#users-zepzeper";

      zep.users.options.admins.zepzeper.sshKeys = sshKeys;

      home-manager.users.zepzeper = {
        imports = [ homeManager."users/zepzeper" ];
        # The release the machine was installed with, like system.stateVersion.
        home.stateVersion = lib.mkDefault config.system.stateVersion;
      };

      age.secrets = {
        # The PHP language server's licence (linked into ~ by the Home
        # Manager half).
        intelephense = lib.mkIf (intelephense != null) (mine intelephense);
        ansible-vault = lib.mkIf (ansibleVault != null) (mine ansibleVault);
      };

      # Read by my ansible repository (get-vault-password.sh) before its own
      # default path.
      environment.variables.ANSIBLE_VAULT_PASSWORD_FILE = lib.mkIf (
        ansibleVault != null
      ) config.age.secrets.ansible-vault.path;
    };

  # Home Manager half.
  flake.modules.homeManager."users/zepzeper" =
    {
      config,
      lib,
      pkgs,
      osConfig,
      ...
    }:
    {
      key = "zep#hm-users-zepzeper";

      home = {
        # Where Go, Cargo, npm and my own scripts put programs, as in
        # zepzeper/dev (npm's global installs cannot go into the Nix store).
        sessionVariables = {
          GOPATH = "$HOME/.local/go";
          NPM_CONFIG_PREFIX = "$HOME/.local";
        };
        sessionPath = [
          "$HOME/.local/bin"
          "$HOME/.local/go/bin"
          "$HOME/.cargo/bin"
          "$HOME/ansible-env/bin"
        ];

        file = {
          # tmux-sessionizer: what every new session starts with (a file next
          # to this one).
          ".tmux-sessionizer".source = ./.tmux-sessionizer;

          # The PHP language server's licence, where my Neovim config reads it.
          "intelephense/license.txt" = lib.mkIf (osConfig.age.secrets ? intelephense) {
            source = config.lib.file.mkOutOfStoreSymlink osConfig.age.secrets.intelephense.path;
          };

          # My ansible repository runs its tools from ~/ansible-env/bin (and
          # its drift check wants a Python with PyYAML there).
          "ansible-env".source = pkgs.buildEnv {
            name = "ansible-env";
            paths = [
              pkgs.ansible
              pkgs.ansible-lint
              (pkgs.python3.withPackages (ps: [ ps.pyyaml ]))
            ];
            ignoreCollisions = true;
          };
        };
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
