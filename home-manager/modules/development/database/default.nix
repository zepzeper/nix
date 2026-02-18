{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    beekeeper-studio
  ];

  nixpkgs.config.permittedInsecurePackages = [
      "beekeeper-studio-5.5.5"
  ];
}
