{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../../../secrets.yaml;

    secrets = {
      "ssh/authorized_keys" = {
        format = "yaml";
        path = "/etc/ssh/authorized_keys/${config.users.users.zepzeper.name}";
      };
    };
  };

  users.users.zepzeper.openssh.authorizedKeys.keys = [
    (lib.sops.mkBase64YAMLEntry "/etc/ssh/authorized_keys/${config.users.users.zepzeper.name}")
  ];
}
