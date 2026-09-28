# Shell

| Block | Switch | What |
| --- | --- | --- |
| `zsh.nix` | `zep.zsh.enable` (on by default, every machine) | zsh as the admins' login shell: oh-my-zsh (robbyrussell; git and fzf plugins), autosuggestions, syntax highlighting, `cat` as bat, the host name in the prompt (green with a desktop, red on a server) |
| `tmux/tmux.nix` | `zep.tmux.enable` (on by default, every machine) | tmux (prefix Ctrl+A, vi copy mode, copies to the system clipboard over OSC 52) with ThePrimeagen's tmux-sessionizer, and a cht.sh cheat sheet |

tmux keys, after the prefix Ctrl+A:

| Key | Does |
| --- | --- |
| `f` | tmux-sessionizer: pick a project, jump to (or create) its session |
| `o` | new window in the current folder |
| `e` | copy mode (`v` select, `y` copy) |
| `i` | cheat sheet: pick a language or command, ask a question |
| `r` | reload the config |
| `Ctrl+A` | send Ctrl+A to the program inside |

Ctrl+F in zsh (outside tmux too) opens tmux-sessionizer.

Configs and scripts stay files, edited as files; the `.nix` next to them only
installs them:

| File | Is |
| --- | --- |
| `tmux/tmux.conf` | the tmux config, `/etc/tmux.conf` |
| `tmux/scripts/cheat` | the cheat sheet script, with its lists in `tmux/scripts/resources/` |
| `../users/zepzeper/tmux-sessionizer.conf` | which folders the sessionizer offers |
| `../users/zepzeper/.tmux-sessionizer` | what every new sessionizer session runs first |

The whole configuration is system-wide (`/etc/zshrc`), so servers without a
Home Manager user get the same shell. People (employees) keep bash.
Something just for this machine or this session goes in `~/.zshrc`, which
zsh still reads after `/etc/zshrc`.
