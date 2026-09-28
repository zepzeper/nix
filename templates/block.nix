# Template for a block. Copy to modules/<category>/<name>.nix and rename.
#
# Every block has the same interface:
#   zep.<name>.enable            turns it on
#   zep.<name>.options.<...>     its settings
# and its whole body sits inside `lib.mkIf cfg.enable`. The `key` lets it be
# imported more than once without "option declared twice" errors.
#
# profiles-base picks the block up automatically, so its option exists on
# every host. Switch it on in a profile or host.
{
  flake.modules.nixos.category-example =
    { config, lib, ... }:
    let
      cfg = config.zep.example;
    in
    {
      key = "zep#category-example";
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

  # A block can carry the user side too, in the same file. It is given to
  # every Home Manager user, so gate it the same way:
  # flake.modules.homeManager.category-example = { config, lib, ... }: {
  #   key = "zep#hm-category-example";
  #   options.zep.example.enable = lib.mkEnableOption "...";
  #   config = lib.mkIf config.zep.example.enable { ... };
  # };
}
