{
  config,
  lib,
  ...
}: let
  cfg = config.modules;
in {
  options.modules = {
    sops = lib.mkEnableOption "SOPS secret management";
  };

  config = lib.mkIf cfg.sops {
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      defaultSopsFile = ../../../secrets.yaml;

      secrets = {
        "ssh_keys/id_ed25519" = {
          path = "${config.home.homeDirectory}/.ssh/id_ed25519";
          mode = "0600";
        };

        "ssh_keys/id_ed25519_chartbuddy" = {
          path = "${config.home.homeDirectory}/.ssh/id_ed25519.chartbuddy";
          mode = "0600";
        };
      };
    };

    home.file.".ssh/.keep" = {
      text = "";
    };
  };
}
