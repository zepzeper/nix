{
  config,
  inputs,
  isNixOS,
  lib,
  outputs,
  pkgs,
  stateVersion,
  username,
  role,
  ...
}: {
  imports = [
    ./modules/dotfiles
    ./modules/development
    ./modules/shell
    ./modules/cli-tools
    ./modules/fonts
    ./modules/scripts
    ./modules/sops
    inputs.sops-nix.homeManagerModules.default
  ];

  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables = lib.mkMerge [
      {
        USER = username;
        EDITOR = "nvim";
      }
      (lib.mkIf (role == "workstation" || role == "desktop") {
        SCREENSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
        SCREENRECORD_DIR = "${config.home.homeDirectory}/Videos/Recordings";
      })
      (lib.mkIf isNixOS {
        NIXOS_OZONE_WL = "1";
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
          "/run/opengl-driver"
        ];
      })
    ];
  };

  modules = lib.mkMerge [
    {
      shell = {
        ssh.enable = lib.mkDefault true;
        zsh.enable = lib.mkDefault true;
      };
      cliTools = {
        git.enable = lib.mkDefault true;
        tmux.enable = lib.mkDefault true;
        screenshot.enable = lib.mkDefault (role == "workstation" || role == "desktop");
        recording.enable = lib.mkDefault (role == "workstation" || role == "desktop");
        terminal = {
          fzf.enable = lib.mkDefault true;
          ghostty.enable = lib.mkDefault true;
          utils = {
            notifications.enable = lib.mkDefault (role == "workstation" || role == "desktop");
            bluetooth.enable = lib.mkDefault (role == "workstation" || role == "desktop");
            fileManager.enable = lib.mkDefault (role == "workstation" || role == "desktop");
            monitoring.enable = lib.mkDefault (role == "workstation" || role == "desktop");
            nightlight.enable = lib.mkDefault (role == "workstation" || role == "desktop");
            coreUtils.enable = lib.mkDefault true;
          };
        };
      };
      fonts = {
        enable = lib.mkDefault true;
      };
      scripts = {
        enable = lib.mkDefault true;
      };
      sops = {
        enable = lib.mkDefault true;
      };
      development = {
        docker.enable = lib.mkDefault true;
        database.enable = lib.mkDefault (role == "workstation" || role == "desktop");
        lsp = {
          common.enable = lib.mkDefault true;
        };
        languages = {
          nix.enable = lib.mkDefault true;
        };
        formatters = {
          alejandra.enable = lib.mkDefault true;
          shfmt.enable = lib.mkDefault true;
        };
        search = {
          ripgrep.enable = lib.mkDefault true;
        };
        kubernetes = {
          enable = lib.mkDefault true;
        };
      };
      dotfiles = {
        enable = lib.mkDefault true;
        nvim = lib.mkDefault true;
        tmux = lib.mkDefault true;
        hypr = lib.mkDefault (role == "workstation" || role == "desktop");
        ghostty = lib.mkDefault (role == "workstation" || role == "desktop");
        waybar = lib.mkDefault (role == "workstation" || role == "desktop");
        walker = lib.mkDefault (role == "workstation" || role == "desktop");
      };
    }
    (lib.mkIf (role == "workstation" || role == "desktop") {
      development.languages = {
        c.enable = lib.mkDefault true;
        zig.enable = lib.mkDefault true;
        go.enable = lib.mkDefault true;
        rust.enable = lib.mkDefault true;
        typescript.enable = lib.mkDefault true;
        lua.enable = lib.mkDefault true;
        php.enable = lib.mkDefault true;
        nix.enable = lib.mkDefault true;
        haskell.enable = lib.mkDefault true;
      };
    })
  ];

  accounts.calendar.basePath = "${config.home.homeDirectory}/.calendar";
  accounts.contact.basePath = "${config.home.homeDirectory}/.contacts";

  fonts.fontconfig.enable = true;

  news.display = "silent";
}
