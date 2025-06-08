{ username, ... }:
{
  homebrew = {
  };


  services.openssh = {
    enable = true;
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "../../keys/nixix/id_ed25519.pub"
  ];
}
