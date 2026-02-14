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
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [];
  };
}
