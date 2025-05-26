# nixos/configuration.nix
{ config, pkgs, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-desktop";
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "Europe/Amsterdam";  # Adjust for your location

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";        # Adjust for your locale
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (if you have a laptop)
  # services.xserver.libinput.enable = true;

  # Define your user account
  users.users.zepzeper = {
    isNormalUser = true;
    description = "zepzeper";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Allow unfree packages (needed for some software)
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    firefox
    alacritty
    gnome.gnome-tweaks  # For GNOME customization
  ];

  # Enable services
  services.openssh.enable = true;
  
  # Enable Docker
  virtualisation.docker.enable = true;

  # Graphics drivers (uncomment what you need)
  # hardware.opengl.enable = true;
  # services.xserver.videoDrivers = [ "nvidia" ];  # For NVIDIA
  # services.xserver.videoDrivers = [ "amdgpu" ];  # For AMD

  # Fonts (same as your macOS config)
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Enable flakes and new nix command
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "zepzeper" ];
  };

  # This value determines the NixOS release
  system.stateVersion = "24.05"; # Don't change this after first install
}
