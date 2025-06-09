{ pkgs, ... }:
{
  imports = [
    ./browsers
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
