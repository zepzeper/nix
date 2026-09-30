{ inputs, ... }:
{
  # What I develop with, ported from the installers in zepzeper/dev (runs/dev,
  # php, rust, odin, docker, vm, ansible, age):
  #
  # - languages: Go (with air for live reload), Node.js, PHP 8.5 with Composer,
  #   Rust through rustup (`rustup default stable` once), Odin, a C compiler;
  # - everyday tools: just, jq, ripgrep, fd, btop, tldr, socat, ffmpeg,
  #   shellcheck, shfmt, unzip;
  # - Docker, and libvirt/QEMU for VMs (virt-install, virt-viewer, and
  #   cloud-localds for cloud-init images), with the admins in the docker and
  #   libvirtd groups;
  # - kustomize (Ansible comes with my user, as the ~/ansible-env my ansible
  #   repository expects);
  # - age and agenix, for the secrets in this repository;
  # - direnv with nix-direnv: a project's development shell (its flake, see
  #   the project templates) loads by itself on `cd`, in tmux sessions and
  #   for Neovim too, and is cached so it stays fast.
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
          php85
          php85.packages.composer
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
          lsof
          tree

          # VMs
          virt-manager # virt-install
          virt-viewer
          cloud-utils # cloud-localds
          cdrkit # genisoimage

          # infrastructure (ansible itself: users/zepzeper, as ~/ansible-env)
          kustomize

          # secrets
          age
          (callPackage "${inputs.agenix}/pkgs/agenix.nix" { })
        ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        virtualisation = {
          docker = {
            enable = true;
            # Docker writes its own iptables rules, past the firewall: a
            # published port (-p 8080:80) would answer the whole network.
            # Bind published ports to localhost unless a run says otherwise
            # (-p 0.0.0.0:8080:80).
            daemon.settings.ip = "127.0.0.1";
          };
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
