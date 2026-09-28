# niri + Noctalia

My workstation desktop: [niri](https://niri-wm.github.io/niri/) 26.04 with
the [Noctalia](https://docs.noctalia.dev/) 5 shell. Unstable channel only.

| File | What |
| --- | --- |
| `niri.nix` | System: niri, login screen (tuigreet), X11 apps, screen recording, Electron on Wayland, the services Noctalia reads; `zep.niri.options.outputs` |
| `home.nix` | My user: niri's config files, Noctalia (as a user service), ghostty |
| `theme.nix` | How apps look: GTK (adw-gtk3), Qt (qt5ct/qt6ct, Fusion), Papirus icons, Bibata cursor |
| `noctalia.toml` | Noctalia's settings |
| `config/` | niri's config, split by subject (see the top of `config/config.kdl`). Checked with `niri validate` at build time and in CI |

Noctalia covers the bar, launcher, notifications, lock screen, idle
(lock after 10 min, screens off after 11), wallpaper, volume/brightness OSD,
clipboard history, screenshots with annotation, night light, the session
menu and the polkit password dialog.

## Colours

Noctalia derives one palette from the wallpaper (or a chosen scheme) and
writes it into the other apps through its theme templates, so everything
changes together:

- GTK apps: `noctalia.css`, imported from `gtk.css` (theme.nix)
- Qt apps: qt5ct/qt6ct colour scheme `noctalia.conf` (theme.nix)
- niri: border and focus colours in `~/.config/niri/noctalia.kdl`
- ghostty: `~/.config/ghostty/themes/noctalia`, included by its config

Before Noctalia has run once these files do not exist yet and apps use their
defaults; `noctalia msg templates-apply` writes them on demand.

## Changing things

- **niri**: edit the files in `config/` and rebuild. To try something first,
  put it in `~/.config/niri/local.kdl` - it overrides the repo config and
  reloads on save.
- **Monitors**: per machine, in its host file:
  `zep.niri.options.outputs = ''output "DP-1" { scale 1.6; }'';`
  (names from `niri msg outputs`). Empty means automatic.
- **Noctalia**: `noctalia.toml` sets the defaults. Changes made in Noctalia's
  settings window (`Mod+Comma`) are kept in
  `~/.local/state/noctalia/settings.toml` and win over the repo; copy the
  lines you keep into `noctalia.toml`.

## Keys

`Mod` is the Super key. `Mod+Shift+/` shows them all on screen.

| Keys | Action |
| --- | --- |
| `Mod+Space`, `Mod+Backspace` | Launcher |
| `Mod+Return`, `Mod+Shift+Delete` | Terminal (ghostty) |
| `Mod+Shift+F` | File manager |
| `Mod+Shift+B` | Browser (Helium, on home.krugten.org) |
| `Mod+S` | Control center |
| `Mod+Comma` | Noctalia settings |
| `Mod+Ctrl+V` | Clipboard history |
| `Mod+N` | Do not disturb |
| `Alt+N` | Night light |
| `Mod+Ctrl+L` | Lock |
| `Mod+Shift+Q` | Session menu (log out, reboot, shut down) |
| `Ctrl+Shift+P`, `Print` | Screenshot a region (clipboard + ~/Pictures/Screenshots) |
| `Ctrl+Print` / `Alt+Print` | Screenshot the screen / the window |
| `Ctrl+Shift+A` | Screenshot and annotate |
| `Ctrl+Shift+R` | Start/stop screen recording (~/Videos/Recordings) |
| `Mod+Q` | Close window |
| `Mod+O` | Overview |
| `Mod+H/J/K/L` | Focus left / down / up / right |
| `Mod+Shift+H/J/K/L` | Move window left / down / up / right |
| `Alt+H/L`, `Alt+K/J` | Narrower/wider column, shorter/taller window |
| `Mod+T` | Float / tile window |
| `Mod+E` | Switch focus between floating and tiled |
| `Mod+F` / `Mod+Ctrl+F` / `Mod+Alt+F` | Fullscreen / fullscreen in a column / full-width column |
| `Mod+R` | Cycle column width (1/3, 1/2, 2/3) |
| `Mod+W` | Tabbed column |
| `Mod+[` / `Mod+]` | Pull window into / push out of the column |
| `Mod+1..0` | Workspace 1-10 |
| `Mod+Shift+1..0` | Move window to workspace (`+Alt`: stay here) |
| `Alt+Shift+H/L` | Move window to workspace above / below |
| `Alt+Tab`, `Mod+Tab` | Recent windows (niri's switcher) |
| `Mod+Shift+P` | Monitors off |

Not carried over from the old Hyprland config: the fixed blue-green border gradient (borders now follow Noctalia's palette; put it back in `local.kdl` if you miss it), app shortcuts for apps not
ported yet (browser, Spotify, web apps), universal copy/paste
(`Mod+C/V/X` - niri cannot send shortcuts to windows), pseudo-tiling, and
typing the e-mail address.
