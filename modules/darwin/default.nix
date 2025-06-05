{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ({ inputs, ... }: import ./homebrew.nix {inherit inputs lib pkgs;})
    ./system.nix
  ];

  # ===== FONTS =====
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # ===== SYSTEM CONFIGURATION =====
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # Set Git commit hash for darwin-version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
