# marchi

An **[Omarchy](https://omarchy.org)-inspired desktop for [Void Linux](https://voidlinux.org)**,
built on the **[niri](https://github.com/YaLTeR/niri)** scrollable-tiling
compositor instead of Hyprland, with **[Waybar](https://github.com/Alexays/Waybar)**
as the bar.

It ports the parts of Omarchy that translate well to Void + niri: the
keybinding muscle memory, a single-source-of-truth theme system, an app
launcher / power menu, screenshots, screen lock & idle, wallpaper management,
and a batteries-included package + service installer that speaks `xbps` and
`runit`.

> This is **not** a fork of Omarchy and does not reuse its Hyprland/Arch
> tooling. It's a fresh, smaller implementation that borrows Omarchy's ideas.
> All credit for the original concept goes to Omarchy and DHH.

## Why niri?

Omarchy is a Hyprland setup. niri is a *scrollable-tiling* compositor — windows
live in an infinite horizontal strip of columns per workspace. The bindings
here keep Omarchy's feel where it makes sense (`SUPER+Return` terminal,
`SUPER+Q` close, `SUPER+1..0` workspaces, `SUPER+F` fullscreen) and adopt
niri-native moves for the column model (consume/expel, preset widths, overview).

## Requirements

- A working **Void Linux** install (glibc or musl) with `sudo`.
- A user in the `wheel` group.
- A GPU that niri supports (most Intel/AMD/NVIDIA work).

## Install

```sh
git clone https://github.com/pamanloki/marchi ~/.local/share/marchi/repo
~/.local/share/marchi/repo/install.sh
```

The installer will:

1. **preflight** — confirm you're on Void with `sudo`.
2. **packages** — `xbps-install` niri, Waybar, foot, fuzzel, mako,
   swaylock/swayidle/swaybg, PipeWire, NetworkManager, Bluetooth, portals,
   polkit, fonts, and a few extras. Missing package names are reported, never
   fatal.
3. **config** — deploy configs to `~/.config`, scripts to `~/.local/bin`,
   themes to `~/.config/marchi/themes`, and apply the default theme. Existing
   configs are backed up to `~/.local/share/marchi/backup-*`.
4. **services** — enable the runit services (`dbus`, `elogind`, `polkitd`,
   `NetworkManager`, `bluetoothd`) and add you to the right groups.
5. **session** — install a `marchi (niri)` Wayland session entry.

Then **reboot**, log in, and pick the **marchi (niri)** session — or from a TTY
run `marchi-session`.

## Keybindings

`SUPER` is the modifier. Press `SUPER+K` any time for a searchable cheat sheet
(or `SUPER+Shift+/` for niri's built-in hotkey overlay).

| Keys | Action |
|------|--------|
| `SUPER+Return` | Terminal |
| `SUPER+Shift+Return` / `SUPER+Shift+B` | Browser |
| `SUPER+E` | File manager |
| `SUPER+Shift+N` | Editor (`$EDITOR`) |
| `SUPER+Space` | App launcher (fuzzel) |
| `SUPER+Escape` | Power / system menu |
| `SUPER+V` | Clipboard history |
| `SUPER+Ctrl+E` | Emoji picker |
| `SUPER+Q` / `SUPER+W` | Close window |
| `SUPER+←↑↓→` / `SUPER+HJKL` | Focus column / window |
| `SUPER+Shift+←↑↓→` | Move column / window |
| `SUPER+1..0` | Focus workspace |
| `SUPER+Shift+1..0` | Move window to workspace |
| `SUPER+F` / `SUPER+Alt+F` | Fullscreen / full-width |
| `SUPER+T` | Toggle floating |
| `SUPER+R` | Cycle preset column widths |
| `SUPER+[` / `SUPER+]` | Consume / expel window |
| `SUPER+O` | Overview |
| `SUPER+C` | Center column |
| `Print` / `Ctrl+Print` / `Alt+Print` | Screenshot region / screen / window |
| `SUPER+Ctrl+L` | Lock screen |
| `SUPER+Ctrl+Shift+Space` | Theme switcher |
| `SUPER+Ctrl+Space` | Wallpaper switcher |
| `SUPER+Shift+E` | Quit niri |

Media, volume, and brightness keys (`XF86*`) are wired to wpctl /
brightnessctl / playerctl.

## Theme system

Each theme is one file — `themes/<name>/colors.sh` — a palette and nothing
else. `marchi-theme-set` reads it and **generates** every derived config
(foot, waybar, mako, swaylock, fuzzel) into
`~/.local/state/marchi/current/theme/`, patches niri's focus-ring colors in
place, and live-reloads the running apps. Deployed configs point at the
generated files, so a switch is instant and consistent.

```sh
marchi theme                 # pick from a menu (or SUPER+Ctrl+Shift+Space)
marchi theme gruvbox         # set directly
marchi theme-list            # list installed themes
```

Bundled themes: **tokyo-night** (default), **catppuccin**, **gruvbox**,
**nord**, **everforest**.

### Add your own theme

Copy any `themes/*/colors.sh`, tweak the colors, drop wallpapers in a
`backgrounds/` folder next to it, and run `marchi theme <name>`.

## Wallpapers

marchi uses `swaybg`. Drop images into a theme's `backgrounds/` folder; if a
theme ships none, marchi falls back to a solid color from the palette.

```sh
marchi wallpaper             # restore current
marchi wallpaper-next        # cycle (or SUPER+Ctrl+Space for the picker)
```

## The `marchi` command

```
marchi theme [name]     marchi wallpaper[-next]     marchi menu
marchi lock             marchi keys                 marchi reload
marchi update           marchi version              marchi help
```

`marchi update` pulls this repo and re-runs the config deploy.

## Layout

```
marchi/
├── install.sh              # entry point
├── install/                # preflight, packages, config, services, session
├── config/                 # niri, waybar, foot (deployed to ~/.config)
├── bin/                    # marchi-* scripts (deployed to ~/.local/bin)
├── themes/<name>/colors.sh # palettes (single source of truth)
└── data/emoji.txt          # emoji picker data
```

## Customizing

- **Terminal / browser / editor / file manager**: set `MARCHI_TERMINAL`,
  `MARCHI_BROWSER`, `MARCHI_GUI_EDITOR`/`EDITOR`, `MARCHI_FILEMANAGER`.
- **Monitors, input, more binds**: edit `~/.config/niri/config.kdl`
  (niri live-reloads it). Colors in that file are managed by the theme system —
  keep the `// marchi:accent` / `// marchi:muted` markers intact.

## License

MIT. Omarchy is a separate project with its own license; this repository does
not include Omarchy code.
