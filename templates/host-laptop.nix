# Template: an employee laptop. Copy to modules/hosts/laptops/<name>.nix and
# replace "laptop-anna" and "anna" throughout.
#
# The laptop profile runs the stable channel, forces disk encryption and
# turns on automatic updates from this repository. The employee's account has no password in here: set
# it with `passwd anna` before handing the laptop over.
{ config, ... }:
{
  flake.modules.nixos."hosts/laptop-anna" = {
    imports = [
      config.flake.modules.nixos.profiles-laptop
      # ./_laptop-anna-hardware.nix
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05"; # the release it was installed with; never change

    zep = {
      disk.options.device = "/dev/disk/by-id/CHANGE-ME";

      # Plasma unless this colleague prefers GNOME:
      # desktop.options.environment = "gnome";

      users.options = {
        admins.zepzeper.sshKeys = [ "ssh-ed25519 AAAA... CHANGE-ME" ];
        people.anna.description = "Anna";
      };
    };
  };
}
