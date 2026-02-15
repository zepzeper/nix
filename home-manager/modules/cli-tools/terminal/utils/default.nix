{pkgs, ...}: {
  home.packages = with pkgs; [
    bluetui
    impala
    wiremix
    btop
    wayfreeze
    walker
    libnotify
    gtk3
    jq
    yq
  ];

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000; # 5 seconds
      background-color = "#1e1e2e";
      font = "JetBrainsMono Nerd Font";
    };
  };
}
