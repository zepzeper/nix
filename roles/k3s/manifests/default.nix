{
  config,
  lib,
  ...
}: let
  cfg = config.k3sManifests;
in {
  options.k3sManifests = {
    enable = lib.mkEnableOption "K3s manifests";
    nginx-ingress = lib.mkEnableOption "Nginx Ingress";
    cert-manager = lib.mkEnableOption "Cert Manager";
    home-assistant = lib.mkEnableOption "Home Assistant";
    pihole = lib.mkEnableOption "Pi-hole";
    vaultwarden = lib.mkEnableOption "Vaultwarden";
    mealie = lib.mkEnableOption "Mealie";
    home-page = lib.mkEnableOption "Homepage";
    monitoring = lib.mkEnableOption "Monitoring";
    tuliprox = lib.mkEnableOption "Tuliprox";
  };

  imports = [
    ./nginx-ingress.nix
    ./cert-manager.nix
    ./home-assistant.nix
    ./pihole.nix
    ./vaultwarden.nix
    ./mealie.nix
    ./homepage.nix
    ./monitoring.nix
    ./tuliprox.nix
  ];
}
