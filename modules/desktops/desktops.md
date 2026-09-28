# Desktops

One setting picks the desktop: `zep.desktop.options.environment`.

| Environment | For | Login screen |
| --- | --- | --- |
| `niri` | my own machines: scrollable-tiling window manager | tuigreet (greetd) |
| `plasma` | colleagues, the laptop default: taskbar and start menu | SDDM |
| `gnome` | colleagues who prefer it | GDM |

`desktop.nix` holds the switch and what every desktop shares: PipeWire
sound, bluetooth (on at boot, so a bluetooth keyboard works at the login
screen), fonts (including Liberation, so Word documents keep their layout).

niri also gets what its default config expects - bar, launcher, terminal,
locker, notifications, media and brightness keys - and a polkit agent, which
programs.niri does not start. Each environment has its own file and only switches on when it is
the one chosen, so a machine can never run two.

Profiles: workstations turn the desktop on; laptops default to `plasma`;
servers force it off and are shell-only, whatever a host sets.

## X11

All three desktops are Wayland. X11 is covered in two ways:

| | X11 apps (XWayland) | X11 session at login |
| --- | --- | --- |
| Plasma | yes (KWin, `programs.xwayland`) | yes, "Plasma (X11)", on by default (`options.x11Session`) |
| GNOME | yes (built into mutter) | no - removed in GNOME 49 |
| niri | yes (xwayland-satellite, started on demand) | no - niri is Wayland-only |

XWayland is the real fallback: an old X11 app just runs. The Plasma X11
session is for the rare case where the whole Wayland session misbehaves on
some hardware. KDE has announced Plasma will drop its X11 session (6.8), so
expect that option to disappear. Turn it off per machine with
`zep.desktop.options.x11Session = false;` to leave Xorg off entirely. (xterm,
which Xorg would add to the start menu, is left out.)
