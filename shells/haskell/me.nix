{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.haskell.compiler.ghc96
    pkgs.git
    pkgs.gcc
    pkgs.gmp
    pkgs.ncurses5
    pkgs.zlib
    pkgs.zlib.dev
    pkgs.gmp.dev
    pkgs.openssl
    pkgs.openssl.dev
    pkgs.pkg-config
    pkgs.glibcLocales
  ];
  
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
      pkgs.gmp
      pkgs.gcc
      pkgs.ncurses5
      pkgs.zlib
      pkgs.openssl
    ]}:$LD_LIBRARY_PATH
    
    export PATH="${pkgs.haskell.compiler.ghc96}/bin:$PATH"
    
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.zlib.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
    
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
  '';
}
