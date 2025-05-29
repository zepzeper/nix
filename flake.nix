{
  description = "Zepzeper's NixOS/Darwin Configuration";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Darwin-specific
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Hyprland
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, nix-darwin, nix-homebrew, home-manager, nixos-hardware, hyprland }:
  let
    # User configuration
    username = "zepzeper";
    
    # Helper function to create shared arguments
    mkSpecialArgs = hostname: system: {
      inherit inputs hostname system username;
      browser = "firefox";
      terminal = "alacritty";
    };
  in
  {
    # Darwin configurations
    darwinConfigurations = {
      "m1-pro" = nix-darwin.lib.darwinSystem {
        specialArgs = mkSpecialArgs "m1-pro" "aarch64-darwin";
        modules = [
          # Your existing service
          ./services/aerospace.nix
          
          # Core darwin configuration (inline for now)
          ({ pkgs, config, ... }: {
            # Allow unfree packages
            nixpkgs.config.allowUnfree = true;
            nixpkgs.hostPlatform = "aarch64-darwin";

            # Minimal system packages
            environment.systemPackages = with pkgs; [
              coreutils
              curl
              libiconv
              wget
              mkalias
            ];

            # Homebrew configuration
            homebrew = {
              enable = true;
              onActivation = {
                autoUpdate = true;
                cleanup = "zap";
              };
              taps = [ "nikitabobko/tap" ];
              casks = [ "aerospace" ];
            };

            # Fonts configuration
            fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

            # Application symlinks
            system.activationScripts.applications.text = let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
              pkgs.lib.mkForce ''
                echo "setting up /Applications..." >&2
                rm -rf /Applications/Nix\ Apps
                mkdir -p /Applications/Nix\ Apps
                find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
                while read -r src; do
                  app_name=$(basename "$src")
                  echo "copying $src" >&2
                  ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
                done
              '';

            # Nix settings
            nix.settings = {
              experimental-features = "nix-command flakes";
              trusted-users = [ "root" username ];
            };

            # Configure the user
            users.users.${username} = {
              name = username;
              home = "/Users/${username}";
              shell = pkgs.zsh;
            };

            # macOS system defaults
            system.defaults = {
              dock.autohide = true;
              finder.FXPreferredViewStyle = "clmv";
              loginwindow.GuestEnabled = false;
              NSGlobalDomain.AppleICUForce24HourTime = true;
              NSGlobalDomain.AppleInterfaceStyle = "Dark";
              NSGlobalDomain.KeyRepeat = 2;
            };

            # Set Git commit hash for darwin-version
            system.configurationRevision = self.rev or self.dirtyRev or null;
            system.stateVersion = 6;
          })

          # Home Manager module
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home/zepzeper.nix;
            home-manager.extraSpecialArgs = mkSpecialArgs "m1-pro" "aarch64-darwin";
          }

          # Homebrew module
          nix-homebrew.darwinModules.nix-homebrew {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;
              autoMigrate = true;
            };
          }
        ];
      };
    };

    # NixOS configurations
    nixosConfigurations = {
      "desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkSpecialArgs "desktop" "x86_64-linux";
        modules = [
          ./hosts/desktop/configuration.nix
        ];
      };
    };

    # Development shells
    devShells = {
      aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
        buildInputs = with nixpkgs.legacyPackages.aarch64-darwin; [
          nixpkgs-fmt
          statix
          deadnix
        ];
      };
      
      x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          nixpkgs-fmt
          statix
          deadnix
        ];
      };
    };

    # Formatters for both platforms
    formatter = {
      aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };

    # Templates for new configurations
    templates.default = {
      path = ./.;
      description = "Zepzeper's NixOS/Darwin flake template";
    };
  };
}
