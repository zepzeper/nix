{
  hostname,
  inputs,
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    
    ../../modules/nixos/common/base.nix
    ../../modules/nixos/common/system
    ../../modules/nixos/common/services

    ../../modules/nixos/server/system
    ../../modules/nixos/server/boot.nix
  ];

  system.stateVersion = "25.05";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        username
      ];
    };
  };

  users.users = {
    ${username} = {
      initialPassword = "changeme";
      isNormalUser = true;
      description = "Server Admin";
      group = "users";
      extraGroups = [
        "wheel"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5BpOI02Rb5C104fjwAK4sIQB6xY64DCqQYNTzGRwQl wouterschiedam98@gmail.com"
      ];
    };
  };

  disko.devices = {
    disk.main = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
