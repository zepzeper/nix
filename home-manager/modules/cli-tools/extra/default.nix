{ config, pkgs, ... }:

let
  prettierNoLicense = pkgs.symlinkJoin {
    name = "prettier-no-license";
    paths = [ pkgs.prettier ];
    postBuild = ''
      rm -f $out/LICENSE
    '';
  };
in {
  home.packages = with pkgs; [
    fzf
    ripgrep
    fd
    gcc
    cmake
    jq
    ffmpeg
    wf-recorder
    mpv
    xorg.xrandr
    imagemagick_light
    glab
    prettierNoLicense

		nodejs
		vscode-extensions.xdebug.php-debug
    php84Packages.composer
    php
  ];

  programs.zsh = {
    shellAliases = {
      grep = "ripgrep";
      find = "fd";
    };
  };
}
