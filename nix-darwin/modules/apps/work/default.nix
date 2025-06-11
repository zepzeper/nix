{ pkgs, ... }:
{
  imports = [
	  ./slack
		./sql
		./tableplus
  ];

  environment.systemPackages = with pkgs; [ ];
}
