{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    localsend
  ];
}
