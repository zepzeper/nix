{ config, pkgs, lib, ... }:

let
  prettierNoLicense = pkgs.symlinkJoin {
    name = "prettier-no-license";
    paths = [ pkgs.prettier ];
    postBuild = ''
      rm -f $out/LICENSE
    '';
  };

  my-python-env = pkgs.python3.withPackages (ps: [
    ps.yt-dlp
    ps.openai-whisper  # This is the new, simplified line
    ps.pip
  ]);

  myPhpIni = pkgs.writeText "php-xdebug.ini" ''
    [xdebug]
    xdebug.mode = debug
    xdebug.start_with_request = yes
    xdebug.client_port = 9003
  '';

  phpWithExtensions = pkgs.php84.withExtensions ({ enabled, all }: [
    all.xdebug      # For debugging
    all.opcache     # Essential for performance
    all.intl        # For internationalization functions
    all.curl        # For making HTTP requests
    all.openssl     # For cryptographic functions
    all.dom         # For XML/DOM manipulation (fixes your last error)
    all.mbstring    # For multi-byte string functions (UTF-8, etc.)
    all.tokenizer   # Required by many frameworks
    all.ctype       # Required by many frameworks
    all.fileinfo    # For detecting file mime types
    all.zip         # For handling .zip archives

    # ---- Database (Choose what you need) ----
    all.pdo         # The main database abstraction layer
    all.pdo_mysql   # Driver for MySQL/MariaDB
    # all.pdo_pgsql # Driver for PostgreSQL
    all.pdo_sqlite # Driver for SQLite

    # ---- Common Utilities ----
    all.bcmath      # For arbitrary precision mathematics
    all.gd          # For image processing
  ]);

  php-with-debugger = pkgs.symlinkJoin {
    name = "php-with-debugger";
    paths = [ phpWithExtensions ]; # Inherit everything from the base package
    postBuild = ''
     makeWrapper ${phpWithExtensions}/bin/php $out/bin/php-debugger-wrapped \
        --add-flags "-c ${myPhpIni}"
      
      # This part remains the same.
      rm $out/bin/php
      mv $out/bin/php-debugger-wrapped $out/bin/php
    '';
    nativeBuildInputs = [ pkgs.makeWrapper ];
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
        yarn
		vscode-extensions.xdebug.php-debug
		php84Packages.composer
		php-with-debugger
        intelephense
		my-python-env
	] ++ lib.optionals stdenv.isLinux [
		wf-recorder
		mpv
		xorg.xrandr
		imagemagick_light
		glab
		libnotify
		hyprshot
	];

    home.file."/intelephense/licence.txt" = {
        text = "00YNPEL2NKC5IE5";
        recursive = true;
    };

  programs.zsh = {
    shellAliases = {
      grep = "rg";
      find = "fd";
    };
  };
}
