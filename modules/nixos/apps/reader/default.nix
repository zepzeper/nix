{
  lib,
  config,
  ...
}: let
  currentDir = ./.;
  isDirectoryAndNotTemplate = name: type: type == "directory";
  directories = lib.filterAttrs isDirectoryAndNotTemplate (builtins.readDir currentDir);
  importDirectory = name: import (currentDir + "/${name}");
  cfg = config.apps.reader;
in {
  imports = lib.mapAttrsToList (name: _: importDirectory name) directories;
}
