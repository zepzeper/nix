{ pkgs, ... }:
{
  imports = [
		./1password
    ./browser
    ./discord
		./karabiner
    ./mail
		./obsidian
		./orbstack
    ./raycast
    ./reader
		./work
  ];

  environment.systemPackages = with pkgs; [ ];
}
