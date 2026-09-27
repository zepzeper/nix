# Template for a block. Copy to modules/<category>/<name>.nix and rename.
#
# Every block has the same interface:
#   zep.<name>.enable            turns it on
#   zep.<name>.options.<...>     its settings
# and its whole body sits inside `lib.mkIf cfg.enable`.
#
# Then add `<category>-<name>` to the imports in
# modules/hosts/profiles/base.nix so the option exists on every host.
{
  flake.modules.nixos.category-example =
    { config, lib, ... }:
    let
      cfg = config.zep.example;
    in
    {
      options.zep.example = {
        enable = lib.mkEnableOption "an example block";

        options.greeting = lib.mkOption {
          type = lib.types.str;
          default = "hello";
          description = "A setting for this block.";
        };
      };

      config = lib.mkIf cfg.enable {
        # An option that would break the machine when left empty asserts at
        # build time instead of failing quietly.
        assertions = [
          {
            assertion = cfg.options.greeting != "";
            message = "zep.example.options.greeting must not be empty.";
          }
        ];

        environment.etc."example".text = cfg.options.greeting;
      };
    };

  # A block can carry the user side too, in the same file:
  # flake.modules.homeManager.category-example = { ... }: { ... };
}
