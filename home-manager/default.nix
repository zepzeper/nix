{
  config,
  inputs,
  isNixOS,
  lib,
  outputs,
  pkgs,
  stateVersion,
  username,
  ...
}:
{
  imports =
    [
      ./modules/dotfiles
      ./modules/neovim
      ./modules/shell
      ./modules/cli-tools
      ./modules/fonts
      ./modules/scripts
      inputs.sops-nix.homeManagerModules.default
      ./modules/sops
    ]
    ++ lib.optionals (isNixOS) [
      ./modules/platforms/nixos
    ];

  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables = lib.mkMerge [
      {
	USER = username;
        EDITOR = "nvim";
      }
      (lib.mkIf isNixOS {
        NIXOS_OZONE_WL = "1";
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
          "/run/opengl-driver"
        ];
      })
    ];
  };

  accounts.calendar.basePath = "${config.home.homeDirectory}/.calendar";
  accounts.contact.basePath = "${config.home.homeDirectory}/.contacts";

  fonts.fontconfig.enable = true;

  news.display = "silent";
}
