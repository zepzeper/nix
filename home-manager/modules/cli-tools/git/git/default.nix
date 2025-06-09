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

		aliases = {
			pushall = "push --recurse-submodules=on-demand";
			pullall = "pull --recurse-submodules=on-demand";
		};

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
