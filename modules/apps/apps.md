# Apps

Programs a person uses. Those that need more than a package (firewall
ports, drivers, a default-app setting) are a block, switched on per host;
plain apps are listed by the host itself in `environment.systemPackages`.

| Block | Switch | What |
| --- | --- | --- |
| `helium.nix` | `zep.helium.enable` | Helium browser, set as the default browser. From the `helium` flake input; `nix flake update helium` for a new release |
| `steam.nix` | `zep.steam.enable` | Steam, with 32-bit graphics drivers and controller support |
| `localsend.nix` | `zep.localsend.enable` | LocalSend, with its port (53317) open to receive files |
| `spotify.nix` | `zep.spotify.enable` | Spotify themed with Spicetify (Comfy theme), from the `spicetify-nix` flake input |
| `firefox.nix` | `zep.firefox.enable` (on for laptops) | Firefox in Dutch and English, telemetry and studies off |
| `office.nix` | `zep.office.enable` (on for laptops) | LibreOffice (still branch; Qt on Plasma) with Dutch and English spelling and Dutch hyphenation |
| `communication.nix` | `zep.communication.enable` (on for laptops) | Thunderbird and the Mattermost desktop app |
| `flatpak.nix` | `zep.flatpak.enable` (on for laptops) | Flatpak with Flathub: people install apps themselves from Discover (Plasma) or Software (GNOME), sandboxed |
