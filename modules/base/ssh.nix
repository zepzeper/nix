{
  # OpenSSH for admins only, with keys only.
  #
  # Forced (a host cannot weaken these): no root login, no passwords, only
  # members of wheel may log in, and keys come only from this repository
  # (users.users.<name>.openssh.authorizedKeys), never from ~/.ssh - so an
  # employee, or malware running as one, cannot add a key and open a door.
  #
  # The crypto (ciphers, key exchange, MACs) is left to nixpkgs: its defaults
  # are already a hardened, modern set, and they gain new algorithms (such as
  # post-quantum key exchange) with each release. A forced list here would
  # freeze them - it already dropped one once.
  #
  # options.openFirewall: servers and my machines accept SSH from the
  # network; laptops do not (their profile turns it off), because they roam
  # on networks nobody here controls. Reach them over a VPN instead.
  flake.modules.nixos.base-ssh =
    { config, lib, ... }:
    let
      cfg = config.zep.ssh;
    in
    {
      key = "zep#base-ssh";
      options.zep.ssh = {
        enable = lib.mkEnableOption "hardened, key-only OpenSSH for admins";

        options = {
          openFirewall = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Accept SSH on every interface. Off on laptops.";
          };
          maxAuthTries = lib.mkOption {
            type = lib.types.ints.positive;
            default = 4;
            description = "Authentication attempts per connection.";
          };
        };
      };

      config = lib.mkIf cfg.enable {
        services.openssh = {
          enable = true;
          inherit (cfg.options) openFirewall;
          authorizedKeysInHomedir = lib.mkForce false;
          settings = {
            PermitRootLogin = lib.mkForce "no";
            PasswordAuthentication = lib.mkForce false;
            KbdInteractiveAuthentication = lib.mkForce false;
            AllowGroups = lib.mkForce [ "wheel" ];
            MaxAuthTries = lib.mkDefault cfg.options.maxAuthTries;
          };
        };
      };
    };
}
