{
  config,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
  };
  
  # Hyprpaper service for wallpapers
  #services.hyprpaper = {
  #  enable = true;
  #  settings = builtins.fromJSON (builtins.readFile "${config.home.homeDirectory}/.dotfiles/hyprland/hyprpaper.json");
  #};

}
