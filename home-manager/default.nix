{
  config,
  inputs,
  isDarwin,
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
      inputs.nixvim.homeManagerModules.default
      ./modules/nixvim
      ./modules/shell
      ./modules/cli-tools
      ./modules/fonts
    ]
    ++ lib.optionals (isDarwin) [
      ./modules/platforms/macos
    ]
    ++ lib.optionals (isNixOS) [
      ./modules/platforms/nixos
    ];

  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

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


  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  news.display = "silent";
}
