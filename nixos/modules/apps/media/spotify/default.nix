{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # For NixOS
    inputs.spicetify-nix.nixosModules.default
  ];
  environment.systemPackages = with pkgs; [
    spotify
  ];
}
