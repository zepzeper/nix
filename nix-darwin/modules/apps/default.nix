{ pkgs, ... }:
{
  imports = [
    ./browser
    ./discord
    ./mail
		./obsidian
		./orbstack
    ./raycast
    ./reader
		./work
  ];

  environment.systemPackages = with pkgs; [ ];
}
