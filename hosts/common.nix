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
  pkgs
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${username} = {pkgs, ...}: {
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
