# k3s-config.nix
{ config, lib, pkgs, meta, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = /var/lib/rancher/k3s/server/token;
    extraFlags = toString [
      "--write-kubeconfig-mode \"0644\""
      "--cluster-init"
      # Comment these out for initial single-node setup
      # "--disable servicelb"
      # "--disable traefik"
      # "--disable local-storage"
    ];
    clusterInit = meta.isMaster;
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
  };

  # Additional packages needed for k3s and longhorn
  environment.systemPackages = with pkgs; [
    kubectl
    helm
    k9s     # Nice terminal UI for Kubernetes
    jq      # Useful for parsing JSON
    iptables
    cifs-utils
    nfs-utils
  ];
}
