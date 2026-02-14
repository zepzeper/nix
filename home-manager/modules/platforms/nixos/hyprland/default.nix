{config, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    withUWSM = true;
  };
}
