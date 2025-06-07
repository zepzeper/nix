{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.fastfetch = {
    enable = true;
    package = pkgs.fastfetch;
    settings = {
      modules = [
        "title"
        "os"
				"wm"
				"editor"
        "terminal"
        "cpu"
        "gpu"
				"memory"
        "battery"
      ];
    };
  };
}
