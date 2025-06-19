{
  config,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile "${config.home.homeDirectory}/.dotfiles/hyprland/hyprland.json");
  };
  
  # Hyprpaper service for wallpapers
  services.hyprpaper = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile "${config.home.homeDirectory}/.dotfiles/hyprland/hyprpaper.json");
  };

	services.mako = {
		enable = true;
		settings = {
			backgroundColor = "#191724";
			textColor = "#e0def4";
			borderColor = "#31748f";
			borderRadius = 12;
			borderSize = 2;
			width = 350;
			height = 100;
			margin = "10";
			padding = "15";
			defaultTimeout = 5000;
		};
		extraConfig = ''
			[urgency=low]
			border-color=#9ccfd8
			
			[urgency=normal]
			border-color=#31748f
			
			[urgency=critical]
			border-color=#eb6f92
			background-color=#26233a
			text-color=#e0def4
		'';
	};
}
