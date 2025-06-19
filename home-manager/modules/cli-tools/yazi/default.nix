{
  config,
  pkgs,
  ...
}:
let
  rose-pine-yazi = pkgs.fetchFromGitHub {
    "owner" = "AlexVolshin";
    "repo" = "rose-pine.yazi";
		"rev" = "da44b3d601616ab60fd590d7b858260d43d9aec5";
		"hash" = "sha256-h6C+xHEVLDQKotqpWq7Xhbcs2977DnQBjK3MUG73AP0=";
  };
in
{
  home.packages = with pkgs; [
    yazi
		ueberzugpp
		poppler-utils
  ];

	programs.yazi = {
		enable = true;
		enableZshIntegration = true;
		shellWrapperName = "y";
		# Use Rose Pine theme
		theme = {
			flavor = {
				dark = "rose-pine";
			};
		};
		flavors = {
			rose-pine = "${rose-pine-yazi}";
		};
		settings = {
			mgr = {
				ratio = [
					2
						4
						3
				];
				sort_by = "alphabetical";
				sort_sensitive = false;
				sort_reverse = false;
				sort_dir_first = true;
				sort_translit = false;
				linemode = "mtime";
				show_hidden = false;
				show_symlink = true;
			};
			preview = {
				wrap = "no";
				tab_size = 2;
				max_width = 600;
				max_height = 900;
				cache_dir = "";
				image_delay = 30;
				image_filter = "triangle";
				image_quality = 75;
				sixel_fraction = 15;
				ueberzug_scale = 1;
				ueberzug_offset = [
					0
					0
					0
					0
				];
			};
			tasks = {
				micro_workers = 10;
				macro_workers = 10;
				bizarre_retry = 3;
				image_alloc = 536870912;
				image_bound = [
					0
					0
				];
				suppress_preload = false;
			};
			edit = [
			{
				run = "${pkgs.neovim}/bin/nvim \"$@\"";
				block = true;
			}
			];
		};
		keymap = {
			mg = {
				prepend_keymap = [
				{
					on = [
						"g"
						"w"
					];
					run = "cd ~/work/";
					desc = "Go to Work";
				}
				{
					on = [
						"g"
						"n"
					];
					run = "cd ~/.dotfiles/nix/";
					desc = "Go to Nix-Config dir";
				}
				{
					on = [
						"g"
							"v"
					];
					run = "cd ~/.dotfiles/nixvim/";
					desc = "Go to Nixvim Config dir";
				}
				{
					on = [
						"g"
						"p"
					];
					run = "cd ~/personal/";
					desc = "Go to Projects";
				}
				];
			};
		};
	};
}
