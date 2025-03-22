{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Very cool tools
    alacritty
    obsidian
    tmux
    ripgrep
    fd
    git
    fzf

    # Programming tools and languages
    gcc
    cmake
    nodejs
    yarn
    maven
    gradle
    jq
    wget
    openssl
    ffmpeg

    # CLI utilities
    htop
    zsh-autosuggestions
    zsh-completions
    stockfish

    # Development tools
    clang-tools # for clang-format
    dotnet-sdk
    zig
    ruby
    go    # Base Go compiler and tools
    gopls # Go language server for LSP support
    air       # Hot reload for Go
    # Optional but helpful tools
    delve  # Go debugger
    golangci-lint # Linter
    go-tools      # Additional analysis tools


    # Databases
    postgresql_14
    redis
    mariadb  # Replaces mysql in nixpkgs

    # Networking tools
    wireguard-tools
    inetutils
    websocat
    curl

    # Microcontroller development
    avrdude

    # QMK tools (keyboard firmware)
    qmk

    # Additional utilities
    watchman

  ] ++ (if stdenv.isDarwin then [
    mas
    reattach-to-user-namespace
  ] else []);
}
