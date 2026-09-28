# Development

| Block | Switch | What |
| --- | --- | --- |
| `neovim.nix` | `zep.neovim.enable` | Neovim as the default editor (`vi`/`vim` too), for a config that installs its own plugins and tools (vim.pack, Mason): nix-ld so Mason's prebuilt programs run, and on Neovim's PATH the toolchains Mason installs through plus a C compiler for tree-sitter |

The Neovim config itself is not in this repository. It is its own repo
(zepzeper/nvim), cloned to `~/personal/nvim` on the first switch and linked
to `~/.config/nvim` (see `modules/users/zepzeper/`). Edit, commit and push it
there like any repo. The first `nvim` start installs the plugins and Mason's
tools.
