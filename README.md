# niri-config

quhongbin's [niri](https://github.com/YaLTeR/niri) scrollable-tiling Wayland
compositor configuration, packaged as a Nix flake with a home-manager module.

## Layout

```
.
├── flake.nix              # entry point — produces homeConfigurations.quhongbin
├── flake.lock             # pinned nixpkgs + home-manager revisions
├── install.sh             # symlink niri/ → ~/.config/niri/
├── niri/
│   ├── default.nix        # home-manager module: installs niri + companion pkgs
│   ├── config.kdl         # the niri config the compositor reads
│   └── dms/               # DMS-generated fragments, linked into live config
│       ├── alttab.kdl
│       ├── binds.kdl
│       ├── colors.kdl
│       ├── cursor.kdl
│       ├── input.kdl
│       ├── layout.kdl
│       ├── outputs.kdl
│       ├── windowrules.kdl
│       └── wpblur.kdl
└── README.md
```

## Prerequisites

Nix with flakes enabled. Add to `~/.config/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

(If the file does not exist yet, create it.)

## Apply

From the repo root:

```sh
# 1. Install niri and the helper packages; register the niri.desktop entry
home-manager switch --flake .#quhongbin

# 2. Link the repo into ~/.config/niri/ so repo = live config
./install.sh
```

The home-manager step installs:

- `niri` (compositor)
- `alacritty`, `fuzzel`, `waybar`, `swaylock`, `swayidle`, `brightnessctl`,
  `playerctl`, `wireplumber`, `pipewire`, `grim`, `slurp`, `wl-clipboard`
- `xdg-desktop-portal-gnome` (screen sharing / file pickers)

…and writes `~/.local/share/applications/niri.desktop` so login managers
(gdm, greetd, tuigreet, …) can offer niri as a session.

The `install.sh` step creates:

- `~/.config/niri/config.kdl` → `niri/config.kdl`
- `~/.config/niri/dms/*.kdl`   → `niri/dms/*.kdl` (one symlink per file)

After both steps, **the repo and the live config are the same files on disk**.

## Edit workflow

```sh
$EDITOR niri/config.kdl                  # edit in repo (= live config)
niri msg action load-config              # hot-reload, no session restart
git add -A && git commit                 # track the change
```

When DankMaterialShell writes to `~/.config/niri/dms/`, the writes actually
land in `niri/dms/` via the symlinks, so theme changes are immediately
git-trackable.

## Customizing

- **Username / home directory / state version** — edit `flake.nix`. Defaults
  to `dev` / `/home/dev` / `25.05`. Don't bump `stateVersion` on an existing
  install without reading the home-manager release notes.
- **Binds / layout / outputs** — edit `niri/config.kdl`, then reload with
  `niri msg action load-config`.
- **Extra packages** — append to `home.packages` in `niri/default.nix`, then
  re-run `home-manager switch --flake .#quhongbin`.

## Pinned versions

- `nixpkgs` → `nixos-25.05`
- `home-manager` → `release-25.05`

These were pinned together because home-manager 25.05 still uses the `fold`
builtin that newer nixpkgs (26.11 / unstable) removed. To upgrade, bump both
together.

## Notes on the current config

`config.kdl` is mostly upstream defaults: gaps 16, focus ring enabled, border
disabled, default column widths of 1/3, 1/2, 2/3, waybar spawned at startup,
and the standard niri bind set (Mod+T alacritty, Mod+D fuzzel, Mod+Q close,
vim-style focus/move, etc.).

The active eDP-1 output block is currently commented out with `/-` — uncomment
it once you have confirmed the correct `mode` and `position` for your display
with `niri msg outputs`.

## Initializing the GitHub repo

```sh
git remote remove origin   # if a placeholder was added
git remote add origin git@github.com:quhongbin/niri-config.git
git push -u origin main
```
