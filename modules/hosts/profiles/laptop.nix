{ config, ... }:
{
  # An employee laptop. A workstation, plus what a machine that leaves the
  # office needs:
  #
  # - Plasma by default, the easiest switch from Windows; a laptop can set
  #   zep.desktop.options.environment = "gnome" instead;
  # - the disk is encrypted (as on every workstation);
  # - SSH does not listen on the network: laptops roam on networks nobody
  #   here controls, and they update themselves anyway;
  # - it updates itself from this repository, so you never have to reach it;
  #   it never reboots on its own, the person decides when;
  # - it runs the stable channel, never unstable: someone else depends on it;
  # - what a colleague needs on day one: Firefox, LibreOffice (Dutch
  #   spelling), Thunderbird and Mattermost, printing and scanning, and the
  #   work VPN (OpenVPN); more apps they install themselves from Flathub;
  # - the disk unlocks with a PIN through the TPM once `enroll-tpm-pin` has
  #   run (the passphrase stays mine, for recovery);
  # - I can reach it: it joins the tailnet, and SSH (my keys only) answers
  #   there, while it stays closed on whatever network the laptop is on.
  flake.modules.nixos.profiles-laptop =
    { lib, hostConfig, ... }:
    {
      key = "zep#profiles-laptop";
      imports = [ config.flake.modules.nixos.profiles-workstation ];

      assertions = [
        {
          assertion = hostConfig.channel == "stable";
          message = "${hostConfig.name}: employee laptops run the stable channel. Remove zep.hosts.${hostConfig.name}.channel = \"unstable\".";
        }
      ];

      zep = {
        desktop.options.environment = lib.mkDefault "plasma";

        ssh.options.openFirewall = lib.mkDefault false;
        tailscale.enable = lib.mkDefault true;

        firefox.enable = lib.mkDefault true;
        office.enable = lib.mkDefault true;
        communication.enable = lib.mkDefault true;
        flatpak.enable = lib.mkDefault true;
        disk.options.tpm2 = lib.mkDefault true;
        printing.enable = lib.mkDefault true;
        networking.options.openvpn = lib.mkDefault true;

        autoUpdate = {
          enable = lib.mkDefault true;
          options.allowReboot = lib.mkForce false;
        };
      };
    };
}
