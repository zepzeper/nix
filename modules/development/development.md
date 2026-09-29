# Development

| Block | Switch | What |
| --- | --- | --- |
| `tools.nix` | `zep.devTools.enable` | languages (Go + air, Node.js, PHP 8.5 + Composer, Rust via rustup, Odin, gcc), everyday CLI tools, Docker, libvirt/QEMU for VMs, kustomize (Ansible: `~/ansible-env`, from `users/zepzeper`), age + agenix, direnv with nix-direnv. Admins join the docker and libvirtd groups |
| `neovim.nix` | `zep.neovim.enable` | Neovim nightly (flake input `neovim-nightly`; `nix flake update neovim-nightly` for a newer one) as the default editor (`vi`/`vim` too), for a config that installs its own plugins and tools (vim.pack, Mason): nix-ld so Mason's prebuilt programs run, and on Neovim's PATH the toolchains Mason installs through plus a C compiler for tree-sitter |

The Neovim config itself is not in this repository. A user names its repo
(`zep.neovim.configRepo = "zepzeper/nvim"` in `modules/users/<name>/`); it
is cloned to `~/personal/nvim` on the first switch and linked to
`~/.config/nvim`. Edit, commit and push it there like any repo. The first
`nvim` start installs the plugins and Mason's tools.

Neovim nightly comes ready built from nix-community's binary cache, which
this block adds; that is why the `neovim-nightly` input keeps its own
nixpkgs (a copy built against ours would never be in that cache).

## Development environments live in the projects

This repository installs the tools I always want; the tools a project needs
belong to the project, as a `flake.nix` with a development shell, pinned in
its own `flake.lock` and committed with it. With direnv the shell loads on
`cd` (also in tmux-sessionizer sessions, and Neovim sees its tools).

A new project, from a template in `templates/projects/`:

```sh
mkdir ~/personal/<project> && cd ~/personal/<project> && git init
nix flake init -t ~/personal/nix#go       # or #php, #node, #rust, #odin, #default
direnv allow
```

A repository where the others do not use Nix (work): keep the shell
outside it, and nothing Nix ends up in their repository:

```sh
mkdir -p ~/personal/devshells/<project> && cd ~/personal/devshells/<project>
nix flake init -t ~/personal/nix#php && git init && git add -A
cd <the work repository>
echo "use flake ~/personal/devshells/<project>" > .envrc
printf '.envrc\n.direnv/\n' >> .git/info/exclude
direnv allow
```
