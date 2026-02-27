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
        ssh = lib.mkDefault true;
        zsh = lib.mkDefault true;
      };
      cliTools = {
        git = lib.mkDefault true;
        tmux = lib.mkDefault true;
        screenshot = lib.mkDefault (role == "workstation" || role == "desktop");
        recording = lib.mkDefault (role == "workstation" || role == "desktop");
        terminal = {
          fzf = lib.mkDefault true;
          ghostty = lib.mkDefault true;
          utils = {
            notifications = lib.mkDefault (role == "workstation" || role == "desktop");
            bluetooth = lib.mkDefault (role == "workstation" || role == "desktop");
            fileManager = lib.mkDefault (role == "workstation" || role == "desktop");
            monitoring = lib.mkDefault (role == "workstation" || role == "desktop");
            nightlight = lib.mkDefault (role == "workstation" || role == "desktop");
            coreUtils = lib.mkDefault true;
          };
        };
      };
      fonts = lib.mkDefault true;
      scripts = lib.mkDefault true;
      sops = lib.mkDefault true;
      development = {
        docker = lib.mkDefault true;
        database = lib.mkDefault (role == "workstation" || role == "desktop");
        lsp = {
          common = lib.mkDefault true;
        };
        languages = {
          nix = lib.mkDefault true;
        };
        formatters = {
          alejandra = lib.mkDefault true;
          shfmt = lib.mkDefault true;
        };
        search = {
          ripgrep = lib.mkDefault true;
        };
        kubernetes = lib.mkDefault true;
        ai = {
          opencode = lib.mkDefault true;
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
        c = lib.mkDefault true;
        zig = lib.mkDefault true;
        go = lib.mkDefault true;
        rust = lib.mkDefault true;
        typescript = lib.mkDefault true;
        lua = lib.mkDefault true;
        php = lib.mkDefault true;
        nix = lib.mkDefault true;
        haskell = lib.mkDefault true;
      };
    })
  ];

  accounts.calendar.basePath = "${config.home.homeDirectory}/.calendar";
  accounts.contact.basePath = "${config.home.homeDirectory}/.contacts";

  fonts.fontconfig.enable = true;

  news.display = "silent";
}
