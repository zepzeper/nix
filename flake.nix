{
  description = "Zepzeper's NixOS & Home Manager Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "github:hyprwm/Hyprland";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nur.url = "github:nix-community/NUR";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    stateVersion = "25.05";
    helper = import ./lib {
      inherit inputs outputs stateVersion;
      lib = nixpkgs.lib;
    };
  in {
    # Home configurations
    homeConfigurations = {
      # Desktop workstation - uses role defaults from home-manager/default.nix
      desktop = helper.mkHome {
        username = "zepzeper";
        hostname = "desktop";
        platform = "x86_64-linux";
        role = "workstation";
      };

      # Laptop - uses role defaults from home-manager/default.nix
      laptop = helper.mkHome {
        username = "zepzeper";
        hostname = "laptop";
        platform = "x86_64-linux";
        role = "workstation";
      };

      # ds10u server - minimal home-manager config
      ds10u = helper.mkHome {
        username = "admin";
        hostname = "ds10u";
        platform = "x86_64-linux";
        role = "server";
        extraHomeModules = [
          {
            modules = {
              dotfiles = {
                enable = true;
                nvim = true;
                tmux = true;
                ghostty = false;
                hypr = false;
                waybar = false;
                walker = false;
              };
              shell = {
                ssh = true;
                zsh = true;
              };
              cliTools = {
                git = true;
                tmux = true;
                screenshot = false;
                recording = false;
                terminal = {
                  enable = true;
                  core = true;
                  utils = false;
                };
              };
              development = {
                docker = true;
                database = false;
                languages = {
                  enable = true;
                  nix = true;
                  go = true;
                  rust = false;
                  c = false;
                  zig = false;
                  typescript = false;
                  lua = false;
                  php = false;
                  haskell = false;
                };
                lsp = {
                  common = {
                    enable = true;
                  };
                };
                formatters = {
                  alejandra = true;
                  shfmt = true;
                };
                search = {
                  ripgrep = true;
                };
                kubernetes = {
                  enable = true;
                };
              };
              fonts = {
                enable = true;
              };
              scripts = {
                enable = true;
              };
              sops = {
                enable = true;
              };
            };
          }
        ];
      };

      # pi server - minimal home-manager config
      pi = helper.mkHome {
        username = "admin";
        hostname = "pi";
        platform = "aarch64-linux";
        role = "server";
        extraHomeModules = [
          {
            modules = {
              dotfiles = {
                enable = true;
                nvim = true;
                tmux = true;
                hypr = false;
                ghostty = false;
                waybar = false;
                walker = false;
              };
              shell = {
                ssh = true;
                zsh = true;
              };
              cliTools = {
                git = true;
                tmux = true;
                screenshot = false;
                recording = false;
                terminal = {
                  enable = true;
                  core = true;
                  utils = false;
                };
              };
              development = {
                docker = true;
                database = false;
                languages = {
                  nix = true;
                  go = true;
                  rust = false;
                  c = false;
                  zig = false;
                  typescript = false;
                  lua = false;
                  php = false;
                  haskell = false;
                };
                lsp = {
                  common = {
                    enable = true;
                  };
                };
                formatters = {
                  alejandra = true;
                  shfmt = true;
                };
                search = {
                  ripgrep = true;
                };
                kubernetes = {
                  enable = true;
                };
              };
              fonts = {
                enable = true;
              };
              scripts = {
                enable = true;
              };
              sops = {
                enable = true;
              };
            };
          }
        ];
      };
    };

    # NixOS configurations
    nixosConfigurations = {
      # Desktop workstation
      desktop = helper.mkWorkstation {
        username = "zepzeper";
        hostname = "desktop";
        platform = "x86_64-linux";
        extraModules = [
          # Desktop-specific hardware
          ./modules/nixos/features/desktop/graphics
          {modules.graphics.gpu = "nvidia";}
          {desktopSettings.bar = true;}
        ];
      };

      # Laptop
      laptop = helper.mkWorkstation {
        username = "zepzeper";
        hostname = "laptop";
        platform = "aarch64-linux";
        extraModules = [
          {desktopSettings.bar = true;}
        ];
      };

      # ds10u server
      ds10u = helper.mkServer {
        username = "admin";
        hostname = "ds10u";
        platform = "x86_64-linux";
        isMasterNode = true;
        isWorkerNode = false;
      };

      # pi server
      pi = helper.mkServer {
        username = "admin";
        hostname = "pi";
        platform = "aarch64-linux";
        isMasterNode = false;
        isWorkerNode = true;
      };
    };

    devShells = nixpkgs.lib.genAttrs ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = [
          inputs.home-manager.packages.${system}.home-manager
        ];
      };
    });
  };
}
