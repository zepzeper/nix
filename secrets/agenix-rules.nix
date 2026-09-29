# Who can decrypt which secret. Read by the agenix command (run it in this
# folder or below), not by the NixOS configuration.
#
# Every secret is encrypted to me (my age key; its private half is
# identity.age, locked with the passphrase in Bitwarden) and to the machines
# that use it (their SSH host key, in hosts/<machine>.pub). A machine whose
# key is not there yet (not installed) is left out until it is.
let
  key = file: builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile file);
  me = key ./recipients/zepzeper.txt;
  for =
    machines:
    [ me ]
    ++ map key (builtins.filter builtins.pathExists (map (name: ./hosts + "/${name}.pub") machines));
in
{
  "tailscale-authkey.age".publicKeys = for [ "zepzeper" ];
  "intelephense.age".publicKeys = for [ "zepzeper" ];
  "ansible-vault.age".publicKeys = for [ "zepzeper" ];
}
