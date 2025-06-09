{ pkgs, ... }:
{
  imports = [
	  ./slack
		./tableplus
  ];

  environment.systemPackages = with pkgs; [ ];
}
