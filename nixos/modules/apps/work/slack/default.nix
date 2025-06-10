{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    slack
		mysql80
  ];
}
