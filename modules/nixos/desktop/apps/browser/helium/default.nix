{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    nur.repos.forkprince.helium-nightly
  ];
}
