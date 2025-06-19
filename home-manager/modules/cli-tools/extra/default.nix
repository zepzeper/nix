{ config, pkgs, lib, ... }:

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
		prettierNoLicense
		go
		nodejs
		vscode-extensions.xdebug.php-debug
		php84Packages.composer
		(php84.withExtensions ({ enabled, all }: enabled ++ [ all.redis ]))
	] ++ lib.optionals stdenv.isLinux [
		wf-recorder
		mpv
		xorg.xrandr
		imagemagick_light
		glab
		postman

		libnotify
		hyprshot
	];

  programs.zsh = {
    shellAliases = {
      grep = "rg";
      find = "fd";
    };
  };
}
