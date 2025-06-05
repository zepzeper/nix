{
  inputs,
  username,
  browser,
  terminal,
  system,
  hostname,
  lib,
  specialArgs,
  config,
  options,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${username} = {pkgs, ...}: {
      imports = [
        ../modules/home/packages.nix 
        ../modules/home/programs/git.nix
        ../modules/home/programs/zsh.nix
        ../modules/home/programs/tmux.nix
        ../modules/home/programs/alacritty.nix
        ../modules/home/programs/neovim.nix
         ] ++ lib.optionals pkgs.stdenv.isDarwin [
           ../modules/home/programs/aerospace.nix
         ] ++ lib.optionals pkgs.stdenv.isLinux [
           ../modules/home/programs/hyprland.nix
      ];
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      xdg.enable = true;
      home.username = username;
      home.homeDirectory =
        if pkgs.stdenv.isDarwin
        then "/Users/${username}"
        else "/home/${username}";
      home.stateVersion = "23.11"; # Please read the comment before changing.
      home.sessionVariables = {
        EDITOR = "nvim";
        BROWSER = browser;
        TERMINAL = terminal;
      };
    };
  };
}
