{ config, pkgs, ... }:
{
  # Install custom scripts to ~/.local/bin
  home.file = {
    ".local/bin/nix-menu" = {
      source = ../../scripts/nix-menu;
      executable = true;
    };
    
    ".local/bin/nix-shot" = {
      source = ../../scripts/nix-shot;
      executable = true;
    };
    
    ".local/bin/nix-rec" = {
      source = ../../scripts/nix-rec;
      executable = true;
    };
    
    ".local/bin/nix-launcher" = {
      source = ../../scripts/nix-launcher;
      executable = true;
    };
  };

  # Ensure ~/.local/bin is in PATH
  home.sessionPath = [ 
    "$HOME/.local/bin"
  ];

  # Shell aliases for convenience
  programs.zsh.shellAliases = {
    menu = "nix-menu";
    shot = "nix-shot";
    rec = "nix-rec";
    launcher = "nix-launcher";
  };
}
