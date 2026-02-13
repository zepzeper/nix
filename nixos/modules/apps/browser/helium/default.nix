{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    inputs.nur.repos.Ev357.helium
    git
  ];
}
