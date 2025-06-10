{pkgs, config, ...}:
let
  primaryUser = builtins.head (builtins.attrNames config.users.users);
  userHome = config.users.users.${primaryUser}.home;
in
{
  environment.systemPackages = [
    pkgs.karabiner-elements
    pkgs.yarn
  ];

  # Activation script to build Karabiner config
  system.activationScripts.karabiner-build = {
    text = ''
      echo "Building Karabiner configuration..."
      if [ -d "${userHome}/.dotfiles/karabiner" ]; then
        cd ${userHome}/.dotfiles/karabiner
        ${pkgs.yarn}/bin/yarn run build
        echo "Karabiner configuration built successfully"
      else
        echo "Warning: Karabiner dotfiles directory not found at ${userHome}/.dotfiles/karabiner"
      fi
    '';
  };
}
