{
  # Neovim, with its configuration kept in its own repository. Which one is
  # personal: zepzeper/nvim is cloned to ~/personal/nvim and linked to
  # ~/.config/nvim by modules/users/zepzeper/.
  #
  # That config manages itself: vim.pack installs the plugins (pinned in its
  # nvim-pack-lock.json) and Mason installs the language servers, linters and
  # formatters. Nix provides what those need underneath:
  #
  # - nix-ld, so the prebuilt programs Mason (and blink.cmp, supermaven)
  #   download run on NixOS: they expect a standard Linux loader and
  #   libraries, which NixOS does not have at the usual paths;
  # - the toolchains Mason installs through (npm, pip, go, composer,
  #   luarocks), a C compiler for tree-sitter parsers, and the tools the
  #   config calls (ripgrep, fd, fzf). They are on Neovim's PATH only, so
  #   they do not leak into the shell.
  #
  # The user half is below; it applies to every Home Manager user of a
  # machine with this block switched on.
  flake.modules.nixos.development-neovim =
    { config, lib, ... }:
    {
      key = "zep#development-neovim";
      options.zep.neovim.enable = lib.mkEnableOption "Neovim with the tools a Mason-based config needs";

      config = lib.mkIf config.zep.neovim.enable {
        programs.nix-ld.enable = true;
      };
    };

  flake.modules.homeManager.development-neovim =
    {
      lib,
      pkgs,
      osConfig,
      ...
    }:
    {
      key = "zep#hm-development-neovim";
      config = lib.mkIf osConfig.zep.neovim.enable {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          # ~/.config/nvim is the cloned repository: Home Manager must not
          # write its init.lua there, so its few lines load from the wrapper.
          sideloadInitLua = true;

          extraPackages = with pkgs; [
            # Mason's installers
            curl
            wget
            unzip
            gzip
            gnutar
            nodejs
            python3
            go
            php
            php.packages.composer
            lua5_1
            luarocks
            # tree-sitter parsers
            gcc
            gnumake
            tree-sitter
            # called by the config
            git
            ripgrep
            fd
            fzf
          ];
        };
      };
    };
}
