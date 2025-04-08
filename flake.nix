{
    description = "Zepzeper darwin system flake";

    inputs = {
        # Core dependencies
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
    };

    outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
        {
            # Darwin configurations
            darwinConfigurations."m1-pro" = nix-darwin.lib.darwinSystem {
                modules = [
                    # self for flake root
                    "${self}/services/aerospace.nix"
                    # Core darwin configuration
                    ({ pkgs, config, ... }: {
                        # Allow unfree packages
                        nixpkgs.config.allowUnfree = true;


                        # Minimal system packages
                        environment.systemPackages = with pkgs; [
                            # Only keep essential system packages here
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
                                cleanup = "zap";  # Removes all unmanaged formulae
                            };
                            taps = [
                                "nikitabobko/tap"
                            ];
                            # Install AeroSpace as a cask
                            casks = [
                                "aerospace"
                            ];
                        };

                        # Fonts configuration
                        fonts.packages = [
                            pkgs.nerd-fonts.jetbrains-mono
                        ];

                        # Application symlinks
                        system.activationScripts.applications.text = let
                            env = pkgs.buildEnv {
                                name = "system-applications";
                                paths = config.environment.systemPackages;
                                pathsToLink = "/Applications";
                            };
                        in
                            pkgs.lib.mkForce ''
                                # Set up applications.
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
                            trusted-users = [ "root" "zepzeper" ];
                        };

                        # Configure the new user in nix-darwin
                        users.users.zepzeper = {
                            name = "zepzeper";
                            home = "/Users/zepzeper";
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

                        # State version
                        system.stateVersion = 6;

                        # Platform
                        nixpkgs.hostPlatform = "aarch64-darwin";
                    })

                    # Home Manager module
                    home-manager.darwinModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.zepzeper = import ./home/zepzeper.nix;
                    }

                    # Homebrew module
                    nix-homebrew.darwinModules.nix-homebrew {
                        nix-homebrew = {
                            enable = true;
                            enableRosetta = true;
                            user = "zepzeper";
                            autoMigrate = true;
                        };
                    }
                ];
            };

            # Add a formatter
            formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
        };
}
