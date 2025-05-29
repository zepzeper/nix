{ config, lib, pkgs, ... }:

{
  config.home.packages = with pkgs; [
    # Core tools (cross-platform)
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
    jq
    wget
    openssl
    ffmpeg

    # CLI utilities
    htop
    zsh-autosuggestions
    zsh-completions
    gtypist
    pwgen
    helmfile
    kustomize

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
    unzip
    zip
    p7zip
    tree
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific packages
    rofi
    steam
    discord
    wl-clipboard       # Clipboard (Wayland)
    neofetch
    btop               # Better htop
    lshw              # Hardware info
    ranger            # Terminal file manager
    vlc               # Media player
    gimp              # Image editing
    docker-compose    # Docker compose tool
    
    # Hyprland ecosystem
    hyprpaper         # Wallpaper daemon
    
    # Theming for Hyprland - Rose Pine
    rose-pine-gtk-theme    # Rose Pine GTK theme
    rose-pine-icon-theme   # Rose Pine icon theme
    rose-pine-hyprcursor   # Rose Pine cursor theme
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-specific packages
    mas
    reattach-to-user-namespace
    karabiner-elements
  ];
}
