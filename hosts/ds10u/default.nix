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
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" username ];
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

  # User configuration
  # Option A: Use hashedPassword for initial setup (comment out after age key is deployed)
  # Option B: Use SOPS for password (uncomment after age key is deployed)
  
  users.users.${username} = {
    description = "Server Admin";
    
    # SSH public key for login
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5BpOI02Rb5C104fjwAK4sIQB6xY64DCqQYNTzGRwQl wouterschiedam98@gmail.com"
    ];
    
    # PHASE 1: Initial deployment - use hashed password
    # Comment this out after you've deployed the age key
    hashedPassword = "$6$18b6ar9iy8VXRanR$htj0EwRHzUnBXEBwtGSk0E0w5raS1QtX3Ge3Y.Z7pRVHHl87MYxJSBYjqWIOR6xrEgMKcyP5sUte6D2IdKzPe/";
    
    # PHASE 2: After age key is deployed - use SOPS
    # Uncomment these lines and comment out hashedPassword above
    # hashedPasswordFile = config.sops.secrets.ds10u-admin-password.path;
  };

  # SOPS secrets configuration
  # PHASE 2: Enable this section after age key is deployed
  # sops.defaultSopsFile = ../../secrets.yaml;
  # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # 
  # sops.secrets.ds10u-admin-password = {
  #   neededForUsers = true;
  # };

  # Firewall ports for server
  networking.firewall = {
    enable = true;
    allowPing = true;
  };
}
