{ inputs, ... }:
{
  # Secrets, with agenix: the encrypted files are in secrets/ at the root of
  # this repository (see secrets/README.md). Each machine decrypts the ones
  # it uses at boot with its SSH host key, into /run/agenix (memory only).
  #
  # Whatever uses a secret asks for it with `secretFile "<name>"` (a module
  # argument): the .age file, or null unless it exists and this machine can
  # decrypt it - its host key in secrets/hosts/ and listed on that secret in
  # secrets/agenix-rules.nix. So a machine builds before its secrets exist,
  # and never tries to decrypt a secret that was not encrypted for it:
  #
  #   { secretFile, ... }: let file = secretFile "<name>"; in {
  #     age.secrets.<name> = lib.mkIf (file != null) { inherit file; };
  #   }
  #
  # and reads it at config.age.secrets.<name>.path. Always imported (no
  # switch): with no secret declared, agenix does nothing.
  flake.modules.nixos.secrets-agenix =
    { config, ... }:
    let
      rules = import ../../secrets/agenix-rules.nix;
      key = file: builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile file);
    in
    {
      key = "zep#secrets-agenix";
      imports = [ inputs.agenix.nixosModules.default ];

      _module.args.secretFile =
        name:
        let
          file = ../../secrets + "/${name}.age";
          hostKey = ../../secrets/hosts + "/${config.networking.hostName}.pub";
          recipients = rules."${name}.age".publicKeys or [ ];
        in
        if
          builtins.pathExists file && builtins.pathExists hostKey && builtins.elem (key hostKey) recipients
        then
          file
        else
          null;
    };
}
