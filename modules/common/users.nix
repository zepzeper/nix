{ lib, config, pkgs, username, ... }:

{
  # User configuration - works for both NixOS and Darwin
  users.users.${username} = {
    name = username;
    shell = pkgs.zsh;
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    # NixOS-specific user options
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "kvm" "video" "audio" "input" "disk" ];
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    # Darwin-specific user options
    home = "/Users/${username}";
  };
}
