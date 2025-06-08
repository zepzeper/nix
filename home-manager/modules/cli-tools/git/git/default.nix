{
  config,
  pkgs,
	username,
  ...
}: {
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    userName = "Zepzeper";
    userEmail = "wouterschiedam98@gmail.com";

		extraConfig = {
			safe = {
				directory = [
					"/home/${username}/.dotfiles"
					"/home/${username}/.dotfiles/nix"
					"/home/${username}/.dotfiles/nixvim"
				];
			};

			core = {
        fileMode = false;  # Ignore file mode changes
        sharedRepository = "group";
      };
		};
  };
}
