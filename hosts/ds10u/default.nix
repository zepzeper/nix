# DS10U server configuration
# Hardware-specific settings for DS10U server
{
  config,
  pkgs,
  lib,
  username,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
  ];

  system.stateVersion = "25.05";

  # Bootloader
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Disk configuration
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

  # Nix settings
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" username];
      trusted-public-keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5BpOI02Rb5C104fjwAK4sIQB6xY64DCqQYNTzGRwQl wouterschiedam98@gmail.com"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Nixpkgs
  nixpkgs.config.allowUnfree = true;

  # User configuration - using SOPS for password
  users.users.${username} = {
    description = "Server Admin";

    # SSH public key for login
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5BpOI02Rb5C104fjwAK4sIQB6xY64DCqQYNTzGRwQl wouterschiedam98@gmail.com"
    ];

    hashedPasswordFile = config.sops.secrets.ds10u-admin-password.path;
  };

  # SOPS secrets configuration
  sops.defaultSopsFile = ../../secrets.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  sops.secrets.tailscale-authkey = {
    owner = "root";
  };

  sops.secrets.k3s-token = {
    owner = "root";
  };

  sops.secrets.cloudflare-api-token = {
    owner = "root";
  };

  sops.secrets.ds10u-admin-password = {
    neededForUsers = true;
  };
}
