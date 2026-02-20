{config, ...}: {
  # SOPS configuration for secret management
  # Decrypts secrets.yaml and places keys in ~/.ssh/
  sops = {
    # Age key location (you'll copy your age private key here after install)
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Path to secrets file
    defaultSopsFile = ../../../secrets.yaml;

    secrets = {
      # Main SSH key
      "ssh_keys/id_ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };

      # Chartbuddy SSH key (if it exists in secrets)
      "ssh_keys/id_ed25519_chartbuddy" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.chartbuddy";
        mode = "0600";
      };
    };
  };

  # Ensure .ssh directory exists with correct permissions
  home.file.".ssh/.keep" = {
    text = "";
  };
}
