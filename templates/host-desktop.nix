# Template: your own desktop. Copy to modules/hosts/clients/<name>.nix and
# replace "desktop" with the machine's name.
#
# Hardware: on the machine, run
#   nixos-generate-config --no-filesystems --show-hardware-config
# and save it next to this file as _<name>-hardware.nix. Files starting with
# "_" are not loaded automatically, only through the import below.
{ config, ... }:
{
  # My own machine: the unstable channel. Laptops and servers must stay on
  # stable (their profiles refuse unstable).
  zep.hosts.desktop.channel = "unstable";

  flake.modules.nixos."hosts/desktop" = {
    imports = [
      config.flake.modules.nixos.profiles-workstation
      # ./_desktop-hardware.nix
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.11"; # `nixos-version` at install time (first two numbers); never change

    zep = {
      desktop.options.environment = "niri";

      # The GPU. For NVIDIA, also the generation (see modules/hardware/graphics.nix):
      # "turing-or-newer" (RTX, GTX 16xx) or "pascal-or-maxwell" (GTX 9xx/10xx).
      graphics.options = {
        gpu = "nvidia";
        nvidiaGeneration = "turing-or-newer";
      };

      # This machine's monitors (names: `niri msg outputs`). Empty: automatic.
      # niri.options.outputs = ''
      #   output "DP-1" {
      #       scale 1.6
      #   }
      # '';

      # Encrypted, with a recovery key (the workstation profile forces it).
      disk.options.device = "/dev/disk/by-id/CHANGE-ME"; # ls -l /dev/disk/by-id/

      users.options.admins.zepzeper.sshKeys = [ "ssh-ed25519 AAAA... CHANGE-ME" ];
    };

    home-manager.users.zepzeper.home.stateVersion = "26.11"; # same as above
  };
}
