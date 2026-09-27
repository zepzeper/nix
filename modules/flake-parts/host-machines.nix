{
  inputs,
  lib,
  config,
  ...
}:
let
  prefix = "hosts/";

  # One NixOS system from one host module, with Home Manager wired in.
  mkHost =
    hostName: module:
    let
      specialArgs = {
        inherit inputs;
        hostConfig.name = hostName;
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      modules = [
        module
        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = lib.mkDefault hostName;
          home-manager.extraSpecialArgs = specialArgs;
        }
      ];
    };
in
{
  # Every module registered as `flake.modules.nixos."hosts/<name>"` becomes
  # `nixosConfigurations.<name>`. Adding a machine is adding one file under
  # modules/hosts; nothing here or in flake.nix changes.
  #
  # Home Manager is wired into every host, so `nh os switch` (or
  # nixos-rebuild) builds the system and the user environment together, and a
  # rollback reverts both.
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (
      name: module:
      let
        hostName = lib.removePrefix prefix name;
      in
      lib.nameValuePair hostName (mkHost hostName module)
    ))
  ];

  # Exposed for checks.nix, which builds stand-in machines from each profile.
  flake.lib.mkHost = mkHost;
}
