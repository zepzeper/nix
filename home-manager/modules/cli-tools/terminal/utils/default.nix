{pkgs, ...}: {
  home.packages = with pkgs; [
    bluetui
    impala
    wiremix
    btop
    wayfreeze
    walker
    libnotify
    gpu-screen-recorder
    jq
    yq
  ];

  services.mako = {
    enable = true;
    settings = {
      defaultTimeout = 5000; # 5 seconds
      backgroundColor = "#1e1e2e";
      textColor = "#cdd6f4";
      borderColor = "#89b4fa";
    };
  };
}
