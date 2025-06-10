{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    karabiner-elements
    yarn
  ];
  
  # Home Manager activation script for macOS
  home.activation.karabiner-build = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "Building Karabiner configuration..."
    if [ -d "$HOME/.dotfiles/karabiner" ]; then
      cd $HOME/.dotfiles/karabiner
      
      # Build the config
      ${pkgs.yarn}/bin/yarn run build
      
      # Copy the generated config file
      if [ -f "./karabiner.json" ]; then
        cp ./karabiner.json ~/.config/karabiner/karabiner.json
        echo "Built and saved config to ~/.config/karabiner/karabiner.json"
      else
        echo "Error: karabiner.json not found after build"
        ls -la .
      fi
      
      # Restart Karabiner Elements
      pkill -f karabiner || true
      sleep 1
      open -a "Karabiner-Elements" 2>/dev/null || true
    else
      echo "Warning: Karabiner dotfiles directory not found at $HOME/.dotfiles/karabiner"
    fi
  '';
}
