{ inputs, ... }:
{
  # What I develop with, ported from the installers in zepzeper/dev (runs/dev,
  # php, rust, odin, docker, vm, ansible, age):
  #
  # - languages: Go (with air for live reload), Node.js, PHP with Composer,
  #   Rust through rustup (`rustup default stable` once), Odin, a C compiler;
  # - everyday tools: just, jq, ripgrep, fd, btop, tldr, socat, ffmpeg,
  #   shellcheck, shfmt, unzip;
  # - Docker, and libvirt/QEMU for VMs (virt-install, virt-viewer, and
  #   cloud-localds for cloud-init images), with the admins in the docker and
  #   libvirtd groups;
  # - Ansible with ansible-lint and kustomize;
  # - age and agenix, for the secrets in this repository.
  #
  # Dropped from the old installers: stow (Nix links the dotfiles now), the
  # cargo-built TUIs for the Hyprland launchers (Noctalia has those panels),
  # and anything pinned to a distro.
  flake.modules.nixos.development-tools =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      admins = lib.attrNames config.zep.users.options.admins;
    in
    {
      key = "zep#development-tools";
      options.zep.devTools.enable = lib.mkEnableOption "languages, Docker, VMs and tools for development";

      config = lib.mkIf config.zep.devTools.enable {
        environment.systemPackages = with pkgs; [
          # languages
          go
          air
          nodejs
          php
          php.packages.composer
          rustup
          odin
          gcc

          # everyday tools
          just
          jq
          ripgrep
          fd
          btop
          tldr
          socat
          ffmpeg
          shellcheck
          shfmt
          unzip

          # VMs
          virt-manager # virt-install
          virt-viewer
          cloud-utils # cloud-localds
          cdrkit # genisoimage

          # infrastructure
          ansible
          ansible-lint
          kustomize

          # secrets
          age
          (callPackage "${inputs.agenix}/pkgs/agenix.nix" { })
        ];

        virtualisation = {
          docker.enable = true;
          libvirtd.enable = true;
        };

        # docker and libvirtd are root in disguise: admins only (people
        # cannot be added to them, see base-users).
        users.users = lib.genAttrs admins (_: {
          extraGroups = [
            "docker"
            "libvirtd"
          ];
        });
      };
    };
}
