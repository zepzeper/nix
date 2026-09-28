# niri + Noctalia

My workstation desktop: [niri](https://niri-wm.github.io/niri/) 26.04 with
the [Noctalia](https://docs.noctalia.dev/) 5 shell. Unstable channel only.

| File | What |
| --- | --- |
| `niri.nix` | System: niri, login screen (tuigreet), X11 apps, screen recording, the services Noctalia reads |
| `home.nix` | My user: niri's config, Noctalia (as a user service) and its defaults, ghostty |
| `config.kdl` | niri's config. Checked with `niri validate` at build time and in CI |

Noctalia covers the bar, launcher, notifications, lock screen, idle
(lock after 10 min, screens off after 11), wallpaper, volume/brightness OSD,
clipboard history, screenshots with annotation, night light, the session
menu and the polkit password dialog.

Changing things:

- **niri**: edit `config.kdl` and rebuild. To try something first, put it in
  `~/.config/niri/local.kdl` - it overrides the repo config and reloads on
  save.
- **Noctalia**: `home.nix` sets defaults. Changes made in Noctalia's settings
  window (`Mod+Comma`) are kept in `~/.local/state/noctalia/settings.toml`
  and win over the repo; move the ones you keep into `home.nix`.

## Keys

`Mod` is the Super key. `Mod+Shift+/` shows them all on screen.

| Keys | Action |
| --- | --- |
| `Mod+Space`, `Mod+Backspace` | Launcher |
| `Mod+Return`, `Mod+Shift+Delete` | Terminal (ghostty) |
| `Mod+Shift+F` | File manager |
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

Not carried over from the old Hyprland config: app shortcuts for apps not
ported yet (browser, Spotify, web apps), universal copy/paste
(`Mod+C/V/X` - niri cannot send shortcuts to windows), pseudo-tiling, and
typing the e-mail address.
