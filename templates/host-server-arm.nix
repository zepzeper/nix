# Template: an ARM server that boots from an SD card. Copy to
# modules/hosts/servers/<name>.nix and replace "server-arm" with its name.
#
# Supported boards: those nixpkgs has U-Boot and device trees for - the
# BCM2711 and BCM2837 SoCs (64-bit), not BCM2712.
#
# No disko: the machine is installed from the NixOS aarch64 SD image and
# keeps that image's partitions (see "Installing an ARM server" in the
# README). It boots through U-Boot, so extlinux instead of systemd-boot.
{ config, ... }:
{
  flake.modules.nixos."hosts/server-arm" = {
    imports = [
      config.flake.modules.nixos.profiles-server
      # Me as admin (SSH keys from modules/users/zepzeper/authorized_keys),
      # with my Home Manager setup and secrets.
      config.flake.modules.nixos."users/zepzeper"
      # ./_server-arm-hardware.nix
    ];

    nixpkgs.hostPlatform = "aarch64-linux";
    system.stateVersion = "26.05"; # `nixos-version` at install time (first two numbers); never change

    zep = {
      boot.options.loader = "extlinux";
      disk.enable = false;
    };

    # The SD image's root filesystem (its label is set by the image builder).
    fileSystems."/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    # The SD image boots with every hardware module available; a configured
    # system only gets what is listed. These are the board's PCIe (USB 3
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
