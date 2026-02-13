{ config, pkgs, ... }:
{
  users.users.zepzeper = {
    isNormalUser = true;
    description = "Wouter";
    group = "users";
    extraGroups = [
      "networkmanager"
      "wheel"
        "video"
        "podman"
    ];
    packages = with pkgs; [
      thunderbird
    ];
    shell = pkgs.zsh;
     openssh.authorizedKeys.keys = [
			 (builtins.readFile ../../../../../keys/m1-mbp/id_ed25519.pub)
     ];
  };
}
