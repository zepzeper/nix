# home/packages-nixos.nix
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Core tools (same as macOS)
    obsidian
    firefox
    tmux
    ripgrep
    fd
    git
    lazygit
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
    qrencode

    # CLI utilities
    htop
    zsh-autosuggestions
    zsh-completions
    gtypist
    pwgen
    helmfile
    kustomize

    # Development tools
    clang-tools
    dotnet-sdk
    zig
    ruby
    php84

    # Go ecosystem
    go
    gopls
    air
    delve
    golangci-lint
    go-tools

    # Rust ecosystem
    rustup
    cargo-generate
    just

    # Databases
    postgresql_14
    redis
    mariadb

    # Networking tools
    wireguard-tools
    inetutils
    websocat
    curl

    # Hardware development
    avrdude
    qmk

    # Additional utilities
    watchman

    # Linux-specific packages (replacements for macOS tools)
    xclip              # Clipboard (X11)
    wl-clipboard       # Clipboard (Wayland)
    
    # System monitoring and info
    neofetch
    btop               # Better htop
    lshw              # Hardware info
    
    # File management
    ranger            # Terminal file manager
    tree              # Directory tree view
    
    # Media and graphics
    vlc               # Media player
    gimp              # Image editing
    
    # Development extras
    docker-compose    # Docker compose tool
    
    # Window management alternatives to AeroSpace
    # (These are optional - GNOME has its own window management)
    # i3                # Tiling window manager
    # rofi              # Application launcher
    
    # Archive tools
    unzip
    zip
    p7zip
  ];
}
