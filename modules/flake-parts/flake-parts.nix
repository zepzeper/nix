{ inputs, ... }:
{
  # Gives us the `flake.modules.<class>.<name>` option. Every block in this
  # repository registers itself there, and hosts import blocks by name.
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # Systems the perSystem outputs (devShell, formatter, checks) are built for.
  # Without this list flake-parts produces nothing for any of them.
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
}
