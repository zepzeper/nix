{
  inputs,
  lib,
  config,
  ...
}:
let
  prefix = "hosts/";

  # What a host is built from, per channel. nixpkgs and Home Manager always
  # move together: a Home Manager branch only supports its own release.
  channels = {
    stable = {
      inherit (inputs) nixpkgs home-manager;
    };
    unstable = {
      nixpkgs = inputs.nixpkgs-unstable;
      home-manager = inputs.home-manager-unstable;
    };
  };

  # One NixOS system from one host module, on the given channel, with Home
  # Manager wired in. `hostConfig` reaches every module, so a profile can
  # check which channel it is on.
  mkHost =
    hostName: channel: module:
    let
      inherit (channels.${channel}) nixpkgs home-manager;
      specialArgs = {
        inherit inputs;
        hostConfig = {
          name = hostName;
          inherit channel;
        };
      };
    in
    nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      modules = [
        module
        home-manager.nixosModules.home-manager
        {
          networking.hostName = lib.mkDefault hostName;
          # Which commit of this repository the system was built from
          # (`nixos-version --configuration-revision`); unset when built
          # from uncommitted changes.
          system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
          home-manager.extraSpecialArgs = specialArgs;
        }
      ];
    };

  hostModules = lib.filterAttrs (name: _: lib.hasPrefix prefix name) config.flake.modules.nixos;
in
{
  # The channel is chosen per host, next to its module:
  #
  #   flake.modules.nixos."hosts/desktop" = { ... };
  #   zep.hosts.desktop.channel = "unstable";
  #
  # It has to live outside the NixOS module because it decides which nixpkgs
  # evaluates that module in the first place.
  options.zep.hosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.channel = lib.mkOption {
          type = lib.types.enum [
            "stable"
            "unstable"
          ];
          default = "stable";
          description = "nixpkgs channel this host is built from.";
        };
      }
    );
    default = { };
    description = "Per-host settings needed before the host's NixOS configuration is evaluated.";
  };

  config.flake = {
    # Every module registered as `flake.modules.nixos."hosts/<name>"` becomes
    # `nixosConfigurations.<name>`. Adding a machine is adding one file under
    # modules/hosts; nothing here or in flake.nix changes.
    #
    # Home Manager is wired into every host, so `nh os switch` (or
    # nixos-rebuild) builds the system and the user environment together, and
    # a rollback reverts both.
    #
    # A zep.hosts entry for a name that has no host (a typo) is caught by
    # checks.nix rather than here, so one typo cannot stop every other
    # machine from evaluating - or from updating itself.
    nixosConfigurations = lib.mapAttrs' (
      name: module:
      let
        hostName = lib.removePrefix prefix name;
        inherit (config.zep.hosts.${hostName} or { channel = "stable"; }) channel;
      in
      lib.nameValuePair hostName (mkHost hostName channel module)
    ) hostModules;

    # Exposed for checks.nix, which builds stand-in machines from each profile.
    lib.mkHost = mkHost;
  };
}
