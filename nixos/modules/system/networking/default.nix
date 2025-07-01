{
  config,
  pkgs,
  hostname,
  ...
}:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      # Listen on localhost only
      listen-address = "127.0.0.1";
      
      # Don't read /etc/resolv.conf
      no-resolv = true;
      
      # Set port to 0 for local caching only
      port = 0;
      
      # Upstream DNS servers
      server = [
        "1.1.1.1"
        "8.8.8.8" 
        "8.8.4.4"
      ];
    };
  };

  networking.networkmanager = {
    enable = true;
    dns = "dnsmasq";
  };
  networking.hostName = hostname;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };
}
