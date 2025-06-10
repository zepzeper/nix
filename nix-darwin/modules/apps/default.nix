{ pkgs, ... }:
{
  imports = [
		./1password
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
