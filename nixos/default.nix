{
  config,
  hostname,
  inputs,
  lib,
  outputs,
  pkgs,
  platform,
  username,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
    ./modules/system
    ./modules/services
    ./modules/apps
  ];

  system.stateVersion = "25.05";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
	username
      ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "${platform}";
    overlays = [
      inputs.nur.overlay or (final: prev: {})
    ];
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    blueman
    cachix
    wl-clipboard
    playerctl
    gparted
    polkit_gnome
    cudaPackages.cudatoolkit
        home-manager
  ];

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

}
