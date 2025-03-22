# home/programs/ssh.nix
{ config, pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_rsa";
      };

      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_rsa";
      };
    };
    
    # Global SSH options
    extraConfig = ''
      AddKeysToAgent yes
      ServerAliveInterval 60
      
      # Any other SSH config options
    '';
  };
  
  home.file.".ssh/config".enable = false;
}
