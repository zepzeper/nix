{
  config,
  pkgs,
  ...
}: {
  # Install neovim but don't manage config - user manages their own
  home.packages = with pkgs; [
    neovim
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
