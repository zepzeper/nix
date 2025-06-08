{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fzf
		ripgrep
		fd
		gcc
		cmake
		jq
		ffmpeg
  ];

	programs.zsh = {
    shellAliases = {
			grep = "ripgrep";
			find = "fd";
		};
	};
}
