{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
		mysql80
  ];
}
