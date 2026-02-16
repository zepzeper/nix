{
  config,
  pkgs,
  ...
}: {
  users.users.zepzeper = {
    isNormalUser = true;
    description = "Wouter";
    group = "users";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [];
  };
}
