{ inputs, config, pkgs, hostname, username, ... }:

{
  imports = [
    ../../services/aerospace.nix
  ];

  # ===== HOST IDENTIFICATION =====
  networking.hostName = hostname;

  # ===== USER CONFIGURATION =====
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
