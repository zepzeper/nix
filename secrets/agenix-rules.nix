# Who can decrypt which secret. Read by the agenix command (run it in this
# folder or below), not by the NixOS configuration.
#
# Every secret is encrypted to me (my age key; its private half is
# identity.age, locked with the passphrase in Bitwarden) and to the machines
# that use it (their SSH host key, in hosts/<machine>.pub).
let
  key = file: builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile file);
  me = key ./recipients/zepzeper.txt;
  host = name: key ./hosts/${name}.pub;
in
{
  "tailscale-authkey.age".publicKeys = [
    me
    (host "zepzeper")
  ];
  "intelephense.age".publicKeys = [
    me
    (host "zepzeper")
  ];
  "ansible-vault.age".publicKeys = [
    me
    (host "zepzeper")
  ];
}
