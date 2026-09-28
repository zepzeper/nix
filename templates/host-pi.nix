# Template: a Raspberry Pi 4 server. Copy to modules/hosts/servers/<name>.nix
# and replace "pi" with the machine's name.
#
# Pi 4 only: nixpkgs has U-Boot and device trees for the Pi 3 and 4, not the
# Pi 5 (see the nixos-raspberrypi project for that).
#
# No disko here: the Pi is installed from the NixOS aarch64 SD image, and
# keeps that image's partitions (see "Installing a Raspberry Pi" in the
# README). It boots through U-Boot, so extlinux instead of systemd-boot.
{ config, ... }:
{
  flake.modules.nixos."hosts/pi" = {
    imports = [
      config.flake.modules.nixos.profiles-server
      # ./_pi-hardware.nix
    ];

    nixpkgs.hostPlatform = "aarch64-linux";
    system.stateVersion = "26.05"; # `nixos-version` at install time (first two numbers); never change

    zep = {
      boot.options.loader = "extlinux";
      disk.enable = false;

      users.options.admins.zepzeper.sshKeys = [ "ssh-ed25519 AAAA... CHANGE-ME" ];
    };

    # The SD image's root filesystem (its label is set by the image builder).
    fileSystems."/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    # The SD image boots with every hardware module available; a configured
    # system only gets what is listed. These are the Pi 4's PCIe (USB 3
    # controller), its USB firmware loader, USB storage and keyboards, and
    # the GPU - without them a USB keyboard or USB SSD is dead at boot.
    boot.initrd.availableKernelModules = [
      "pcie-brcmstb"
      "reset-raspberrypi"
      "usb_storage"
      "usbhid"
      "vc4"
    ];
  };
}
