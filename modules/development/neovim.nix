{ inputs, ... }:
{
  # Neovim nightly (the `neovim-nightly` flake input, built from Neovim's
  # main branch), for a configuration that lives in its own repository and
  # manages itself: vim.pack installs the plugins and Mason installs the
  # language servers, linters and formatters.
  #
  # System half (a host switches it on with zep.neovim.enable):
  # - nix-ld, so the prebuilt programs Mason (and supermaven) download run
  #   on NixOS: they expect a standard Linux loader at /lib64, which NixOS
  #   does not have;
  # - nix-community's binary cache, where Neovim nightly comes from ready
  #   built.
  #
  # User half (Home Manager, every user of such a machine):
  # - Neovim as the editor (EDITOR, vi, vim), with on its PATH only the
  #   toolchains Mason installs through, a C compiler for tree-sitter
  #   parsers, and the tools the config calls;
  # - the config: the repository a user names in zep.neovim.configRepo is
  #   cloned to ~/personal/<name> and linked to ~/.config/nvim, so it stays a
  #   normal checkout to edit, commit and push. Cloned on a switch when it is
  #   missing, over https (no key needed; pushing goes over ssh). Without a
  #   network it is simply tried again on the next switch.
  flake.modules.nixos.development-neovim =
    { config, lib, ... }:
    {
      key = "zep#development-neovim";
      options.zep.neovim.enable = lib.mkEnableOption "Neovim nightly with the tools a Mason-based config needs";

      config = lib.mkIf config.zep.neovim.enable {
        programs.nix-ld.enable = true;

        nix.settings = {
          substituters = [ "https://nix-community.cachix.org" ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };
    };

  flake.modules.homeManager.development-neovim =
    {
      config,
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      cfg = config.zep.neovim;
      repoDir = "${config.home.homeDirectory}/personal/${baseNameOf cfg.configRepo}";
      gitExe = lib.getExe pkgs.git;
    in
    {
      key = "zep#hm-development-neovim";

      options.zep.neovim.configRepo = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "zepzeper/nvim";
        description = "GitHub repository (owner/name) with this user's Neovim config.";
      };

      config = lib.mkIf osConfig.zep.neovim.enable (
        lib.mkMerge [
          {
            programs.neovim = {
              enable = true;
              package = inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default;
              defaultEditor = true;
              viAlias = true;
              vimAlias = true;
              # ~/.config/nvim is the user's repository: Home Manager must not
              # write its init.lua there, so its few lines load from the wrapper.
              sideloadInitLua = true;

              extraPackages = with pkgs; [
                # Mason's installers
                curl
                unzip
                gzip
                gnutar
                nodejs
                python3
                go
                php85
                php85.packages.composer
                luarocks
                # tree-sitter parsers (the tree-sitter CLI itself comes from Mason)
                gcc
                # called by the config
                git
                ripgrep
                fd
                fzf
              ];
            };
          }

          (lib.mkIf (cfg.configRepo != null) {
            xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink repoDir;

            home.activation.cloneNeovimConfig =
              lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
                ''
                  if [ ! -e "${repoDir}" ]; then
                    run mkdir -p "$(dirname "${repoDir}")"
                    if run ${gitExe} clone "https://github.com/${cfg.configRepo}" "${repoDir}"; then
                      run ${gitExe} -C "${repoDir}" remote set-url --push origin "git@github.com:${cfg.configRepo}.git"
                    else
                      warnEcho "Could not clone ${cfg.configRepo} to ${repoDir}; it is tried again on the next switch."
                    fi
                  fi
                '';
          })
        ]
      );
    };
}
