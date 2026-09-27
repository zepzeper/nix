# Desktops

One setting picks the desktop: `zep.desktop.options.environment`.

| Environment | For | Login screen |
| --- | --- | --- |
| `niri` | my own machines: scrollable-tiling window manager | tuigreet (greetd) |
| `plasma` | colleagues, the laptop default: taskbar and start menu | SDDM |
| `gnome` | colleagues who prefer it | GDM |

`desktop.nix` holds the switch and what every desktop shares: PipeWire
sound, bluetooth, fonts (including Liberation, so Word documents keep their
layout). Each environment has its own file and only switches on when it is
the one chosen, so a machine can never run two.

Profiles: workstations turn the desktop on; laptops default to `plasma`;
servers force it off and are shell-only, whatever a host sets.
