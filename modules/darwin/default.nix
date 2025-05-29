{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./homebrew.nix
    ./system.nix
  ];

  # ===== FONTS =====
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # ===== APPLICATION SYMLINKS =====
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

  # ===== MINIMAL SYSTEM PACKAGES =====
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    libiconv
    wget
    mkalias
  ];

  # ===== SYSTEM CONFIGURATION =====
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # Set Git commit hash for darwin-version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
