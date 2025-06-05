{ inputs, config, pkgs, hostname, username, ... }:

{
  imports = [
    ../../modules/darwin/default.nix
    ../../modules/common/default.nix
   # ../common.nix
  ];

  # ===== HOST IDENTIFICATION =====
  networking.hostName = hostname;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
}
