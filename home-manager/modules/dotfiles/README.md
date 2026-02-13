# Dotfiles Integration

This module automatically symlinks your dotfiles from the git submodule at `~/personal/nix/dotfiles` to the appropriate locations.

## Git Submodule Setup

The dotfiles are managed as a git submodule pointing to `git@github.com:zepzeper/.dotfiles.git`.

### Cloning the repo with submodules:

```bash
git clone --recurse-submodules git@github.com:zepzeper/nix.git
```

### If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

### Updating dotfiles submodule to latest:

```bash
cd ~/personal/nix
git submodule update --remote
git add dotfiles
git commit -m "Update dotfiles submodule"
```

### Making changes to dotfiles:

```bash
cd ~/personal/nix/dotfiles
# Make your changes
git add .
git commit -m "Your changes"
git push

# Then in the main nix repo:
cd ~/personal/nix
git add dotfiles
git commit -m "Update dotfiles"
git push
```

## Currently Managed Dotfiles

| Dotfile | Target Location | Description |
|---------|----------------|-------------|
| nvim | `~/.config/nvim` | Neovim configuration |
| hypr | `~/.config/hypr` | Hyprland window manager config |
| ghostty | `~/.config/ghostty` | Ghostty terminal config |
| tmux | `~/.tmux.conf` | Tmux configuration |
| zsh | `~/.zshrc` | Zsh shell configuration |

## Adding New Dotfiles

To add more dotfiles, edit `home-manager/modules/dotfiles/default.nix`:

### For XDG config files (`~/.config/`):

```nix
xdg.configFile."<app-name>" = {
  source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/<dotfile-folder>";
  recursive = true;
};
```

### For home directory files (`~/`):

```nix
home.file.".<filename>" = {
  source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/<path-to-file>";
};
```

## Example: Adding ghostty

```nix
xdg.configFile."ghostty" = {
  source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/ghostty";
  recursive = true;
};
```

## Example: Adding zsh config

```nix
home.file.".zshrc" = {
  source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zsh/.zshrc";
};
```

## How It Works

- Uses `mkOutOfStoreSymlink` to create symlinks pointing to your dotfiles submodule
- Changes in `~/personal/nix/dotfiles` are immediately reflected (no rebuild needed)
- The symlinks are created when you run `home-manager switch`
- If the target directory doesn't exist in your dotfiles, the symlink will fail

## Troubleshooting

### Submodule not updating:
```bash
git submodule update --init --recursive --force
```

### If symlinks aren't working:
1. Check that `~/personal/nix/dotfiles` exists
2. Verify the specific config folder exists (e.g., `~/personal/nix/dotfiles/nvim`)
3. Run `home-manager switch` to recreate symlinks
4. Check for broken symlinks: `ls -la ~/.config/ | grep "^l"`

### Detached HEAD in submodule:
```bash
cd ~/personal/nix/dotfiles
git checkout main  # or master, depending on your default branch
```
