{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services;
in {
  options.services = {
    ollama-c = lib.mkEnableOption "Ollama";
  };

  config = lib.mkIf cfg.ollama-c {
    environment.systemPackages = [pkgs.ollama];
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda; # For NVIDIA GPUs
    };
  };
}
