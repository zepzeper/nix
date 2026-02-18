{
  config,
  pkgs,
  hostname,
  ...
}: {
  networking.networkmanager = {
    enable = true;
  };

  networking.hostName = hostname;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
  };
}
