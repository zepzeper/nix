# Shell

| Block | Switch | What |
| --- | --- | --- |
| `zsh.nix` | `zep.zsh.enable` (on by default, every machine) | zsh as the admins' login shell: oh-my-zsh (robbyrussell; git and fzf plugins), autosuggestions, syntax highlighting, `cat` as bat, the host name in the prompt (green with a desktop, red on a server) |

The whole configuration is system-wide (`/etc/zshrc`), so servers without a
Home Manager user get the same shell. People (employees) keep bash.
Something just for this machine or this session goes in `~/.zshrc`, which
zsh still reads after `/etc/zshrc`.
