{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "zepzeper";  # Replace with your actual git username
    userEmail = "wouterschiedam98@gmail.com";  # Replace with your email
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
