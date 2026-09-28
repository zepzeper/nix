{ inputs, ... }:
{
  # Secrets, with agenix: the encrypted files are in secrets/ at the root of
  # this repository (see secrets/README.md). Each machine decrypts the ones
  # it uses at boot with its SSH host key, into /run/agenix (memory only).
  #
  # Whatever uses a secret declares it, and only once its file exists, so a
  # machine builds before its secrets have been added:
  #
  #   age.secrets.<name> = lib.mkIf (builtins.pathExists file) { inherit file; };
  #
  # and reads it at config.age.secrets.<name>.path. Always imported (no
  # switch): with no secret declared, agenix does nothing.
  flake.modules.nixos.secrets-agenix = {
    key = "zep#secrets-agenix";
    imports = [ inputs.agenix.nixosModules.default ];
  };
}
