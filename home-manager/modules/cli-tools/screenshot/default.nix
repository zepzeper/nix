{pkgs, ...}: {
  home.packages = with pkgs; [
    grim
    slurp
    satty
    hyprshot
    wl-clipboard
  ];
}
