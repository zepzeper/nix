{
  # OpenSSH, key-only. The crypto floor and login policy are forced so a host
  # cannot weaken them by accident; maxAuthTries is a default a host may tune.
  # Settings follow the NCSC/CIS guidance DAWO-NixOS uses.
  flake.modules.nixos.base-ssh =
    { config, lib, ... }:
    let
      cfg = config.zep.ssh;
    in
    {
      options.zep.ssh = {
        enable = lib.mkEnableOption "hardened, key-only OpenSSH";

        options.maxAuthTries = lib.mkOption {
          type = lib.types.ints.positive;
          default = 4;
          description = "Authentication attempts per connection.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.openssh = {
          enable = true;
          openFirewall = lib.mkDefault true;
          settings = {
            PermitRootLogin = lib.mkForce "no";
            PasswordAuthentication = lib.mkForce false;
            KbdInteractiveAuthentication = lib.mkForce false;
            X11Forwarding = lib.mkForce false;
            MaxAuthTries = lib.mkDefault cfg.options.maxAuthTries;
            Ciphers = lib.mkForce [
              "chacha20-poly1305@openssh.com"
              "aes256-gcm@openssh.com"
              "aes128-gcm@openssh.com"
            ];
            KexAlgorithms = lib.mkForce [
              "sntrup761x25519-sha512@openssh.com"
              "curve25519-sha256"
              "curve25519-sha256@libssh.org"
            ];
            Macs = lib.mkForce [
              "hmac-sha2-512-etm@openssh.com"
              "hmac-sha2-256-etm@openssh.com"
            ];
          };
        };
      };
    };
}
