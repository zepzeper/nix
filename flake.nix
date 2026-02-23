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
      desktop = helper.mkMachine {
        username = "zepzeper";
        hostname = "desktop";
        platform = "x86_64-linux";
        roleSettings = [{
            workstation = true;
        }];
        serviceSettings = [{
            features = {
                audio = true; 
                waybar = true; 
                dm = true; 
                gpu = "nvidia";
                networking = true; 
                peripherals = true; 
            };
            services = {
                docker = true;
                openrgb = true;
                xdg = true;
            };
            apps = {
                browser = {
                    helium = true;
                };
                creative = {
                    gimp = true;
                };
                media = {
                    hypnotix = true;
                    localsend = true;
                    spotify = true;
                    vlc = true;
                };
                reader = {
                    files = {
                        nautilus = true;
                    };
                };
                steam = true;
            };
        }];
      };

      # Laptop
      laptop = helper.mkMachine {
        username = "zepzeper";
        hostname = "laptop";
        platform = "aarch64-linux";
        roleSettings = [{
            workstation = true;
        }];
        serviceSettings = [{
            features = {
                audio = true; 
                waybar = true; 
                dm = true; 
                gpu = "none";
                networking = true; 
                peripherals = true; 
            };
            services = {
                docker = true;
                xdg = true;
            };
            apps = {
                browser = {
                    helium = true;
                };
                creative = {
                    gimp = true;
                };
                media = {
                    hypnotix = true;
                    localsend = true;
                    spotify = true;
                    vlc = true;
                };
                reader = {
                    files = {
                        nautilus = true;
                    };
                };
            };
        }];
      };

      # ds10u server
      ds10u = helper.mkMachine {
        username = "admin";
        hostname = "ds10u";
        platform = "x86_64-linux";
        roleSettings = [{
            server = true;
            k3s = {
              master = true;
            };
        }];
        serviceSettings = [{
            features = {
                audio = true; 
                networking = true; 
            };
            services = {
                docker = true;
                xdg = true;
            };
        }];
      };

      # pi server
      pi = helper.mkMachine {
        username = "admin";
        hostname = "pi";
        platform = "aarch64-linux";
        roleSettings = [{
            server = true;
            k3s = {
              worker = true;
            };
        }];
        serviceSettings = [{
            features = {
                audio = true; 
                networking = true; 
            };
            services = {
                docker = true;
                xdg = true;
            };
        }];
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
