{
  config,
  lib,
  ...
}: {
  sops = {
    defaultSopsFile = ../../../../secrets.yaml;

    #secrets = {
    #  "ssh.authorized_keys" = {
    #    format = "yaml";
    #    path = "/etc/ssh/authorized_keys/${config.users.users.zepzeper.name}";
    #  };
    #};
  };

  #users.users.zepzeper.openssh.authorizedKeys.keys = [
  #      config.sops.secrets."ssh.authorized_keys".path
  #];
}
