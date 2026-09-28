{ inputs, ... }:
{
  # Secrets, with agenix: the encrypted files are in secrets/ at the root of
  # this repository (see secrets/README.md). Each machine decrypts the ones
  # it uses at boot with its SSH host key, into /run/agenix (memory only).
  #
  # Whatever uses a secret asks for it with `secretFile "<name>"` (a module
  # argument): the .age file, or null while it is missing or this machine
  # has no host key in secrets/hosts/ yet. So a machine builds before its
  # secrets exist, and a machine that was never added cannot fail to decrypt
  # (one that was added also has to be listed on the secret, in
  # secrets/agenix-rules.nix):
  #
  #   { secretFile, ... }: let file = secretFile "<name>"; in {
  #     age.secrets.<name> = lib.mkIf (file != null) { inherit file; };
  #   }
  #
  # and reads it at config.age.secrets.<name>.path. Always imported (no
  # switch): with no secret declared, agenix does nothing.
  flake.modules.nixos.secrets-agenix =
    { config, ... }:
    {
      key = "zep#secrets-agenix";
      imports = [ inputs.agenix.nixosModules.default ];

      _module.args.secretFile =
        name:
        let
          file = ../../secrets + "/${name}.age";
          hostKey = ../../secrets/hosts + "/${config.networking.hostName}.pub";
        in
        if builtins.pathExists file && builtins.pathExists hostKey then file else null;
    };
}
