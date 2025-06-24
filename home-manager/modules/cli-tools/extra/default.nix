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
		(php84.withExtensions ({ enabled, all }: enabled ++ [ 
			all.xdebug
		]))
	] ++ lib.optionals stdenv.isLinux [
		wf-recorder
		mpv
		xorg.xrandr
		imagemagick_light
		glab
		libnotify
		hyprshot
	];

	home.file.".config/php/php.ini".text = ''
    [debug]
    xdebug.mode = debug
    xdebug.start_with_request = yes
    xdebug.client_port = 9003
  '';

  home.sessionVariables = {
    PHP_INI_SCAN_DIR = "${config.home.homeDirectory}/.config/php";
  };

  programs.zsh = {
    shellAliases = {
      grep = "rg";
      find = "fd";
    };
  };
}
