_:
let
  wallpaper_path = ./wallpapers/wall-2.png;
in
{
  homebrew = {
    casks = [ "desktoppr" ];
  };

  system.activationScripts.postActivation.text = ''
        echo "Setting wallpaper to ${wallpaper_path}..."
    		/usr/local/bin/desktoppr ${wallpaper_path}
  '';
}
