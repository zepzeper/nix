# modules/php-packages.nix
{ pkgs }:

let
  unstablePkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
  customPhp = unstablePkgs.php.buildEnv {
    extensions = { all, enabled }: with all; enabled ++ [
      # Core extensions from your Dockerfile
      soap
      simplexml
      xml
      xsl
      zip
      intl
      mysqli
      pdo
      pdo_mysql
      bz2
      gd
      gettext
      bcmath
      mbstring
      opcache
      
      # PECL extensions
      xdebug
      imap
    ];
    extraConfig = ''
      # Xdebug configuration
      xdebug.mode = debug
      xdebug.start_with_request = yes
      xdebug.client_host = localhost
      xdebug.client_port = 9003
      xdebug.log = /tmp/xdebug.log
      
      # Other PHP configuration settings from php.ini
      memory_limit = 256M
      upload_max_filesize = 64M
      post_max_size = 64M
      max_execution_time = 300
    '';
  };
  
  # Create a convenient shell script for entering the environment
  php-shell = pkgs.writeShellScriptBin "php-shell" ''
    echo "Entering PHP development environment..."
    exec ${pkgs.mkShell {
      buildInputs = with pkgs; [
        # PHP and Composer
        customPhp
        customPhp.packages.composer
        
        # System dependencies from your Dockerfile
        wget
        unzip
        libxml2
        zlib
        icu
        libjpeg
        libpng
        freetype
        libzip
        libxslt
        bzip2
        git
        
        # Database
        mariadb
        
        # Apache
        apacheHttpd
        
        # Additional useful tools
        phpPackages.phpcbf
        phpPackages.phpcs
        phpPackages.phpstan
      ];
      
      shellHook = ''
        export MYSQL_HOME=$HOME/.mysql
        export PHP_INI_SCAN_DIR=''${PHP_INI_SCAN_DIR:-}:${customPhp}/lib/php/
        
        echo "PHP development environment loaded."
        echo "PHP version: $(php --version | head -n 1)"
        echo "Composer version: $(composer --version)"
        
        # Uncomment and modify to automatically cd to your project directory
        # cd /path/to/your/project
        
        # Start Apache if needed
        echo "Starting Apache..."
        ${pkgs.apacheHttpd}/bin/httpd -f /path/to/your/httpd.conf
      '';
    }}/bin/nix-shell
  '';
  
  # Create a utility script to start the Apache server
  apache-start = pkgs.writeShellScriptBin "apache-start" ''
    HTTPD_ROOT="$HOME/.config/apache"
    
    # Create Apache directories if they don't exist
    mkdir -p $HTTPD_ROOT/logs
    mkdir -p $HTTPD_ROOT/conf
    
    # Create basic config if it doesn't exist
    if [ ! -f "$HTTPD_ROOT/conf/httpd.conf" ]; then
      echo "Creating default Apache configuration..."
      cat > $HTTPD_ROOT/conf/httpd.conf << EOF
    ServerRoot "${pkgs.apacheHttpd}"
    Listen 8080
    LoadModule authz_core_module modules/mod_authz_core.so
    LoadModule authz_host_module modules/mod_authz_host.so
    LoadModule dir_module modules/mod_dir.so
    LoadModule mime_module modules/mod_mime.so
    LoadModule rewrite_module modules/mod_rewrite.so
    LoadModule php_module ${customPhp}/lib/httpd/modules/libphp.so
    
    PidFile "$HTTPD_ROOT/logs/httpd.pid"
    ErrorLog "$HTTPD_ROOT/logs/error_log"
    
    <Directory />
      AllowOverride none
      Require all denied
    </Directory>
    
    DocumentRoot "$HOME/www"
    <Directory "$HOME/www">
      Options Indexes FollowSymLinks
      AllowOverride All
      Require all granted
    </Directory>
    
    <FilesMatch \.php$>
      SetHandler application/x-httpd-php
    </FilesMatch>
    
    DirectoryIndex index.html index.php
    EOF
      
      # Create a www directory if it doesn't exist
      mkdir -p $HOME/www
      
      # Create a test PHP file
      if [ ! -f "$HOME/www/index.php" ]; then
        echo "<?php phpinfo(); ?>" > $HOME/www/index.php
      fi
    fi
    
    echo "Starting Apache on http://localhost:8080..."
    exec ${pkgs.apacheHttpd}/bin/httpd -f $HTTPD_ROOT/conf/httpd.conf -DFOREGROUND
  '';
in [
  # Main PHP environment
  customPhp
  customPhp.packages.composer
  
  # Shell and utility scripts
  php-shell
  apache-start
  
  # Apache
  pkgs.apacheHttpd
  
  # Additional development tools
  pkgs.phpPackages.phpcbf
  pkgs.phpPackages.phpcs
  pkgs.phpPackages.phpstan
]
