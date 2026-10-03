# niri-config

quhongbin's [niri](https://github.com/YaLTeR/niri) scrollable-tiling Wayland
compositor configuration, packaged as a Nix flake with a home-manager module.

## Layout

```
.
├── flake.nix              # entry point — produces homeConfigurations.quhongbin
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

1. **Nix with flakes enabled.** Add to `~/.config/nix/nix.conf`:
   ```ini
   experimental-features = nix-command flakes
   ```
   If that file does not exist yet, create it.

2. **home-manager.** Easiest is to run it through the flake (`nix run home-manager`),
   which fetches a pinned copy — no system-wide install needed.

## Apply

From the repo root:

```sh
home-manager switch --flake .#quhongbin
```

That installs `niri` and the helper packages the binds assume (`alacritty`,
`fuzzel`, `waybar`, `swaylock`, `swayidle`, `brightnessctl`, `playerctl`,
`wireplumber`, `pipewire`, `grim`, `slurp`, `wl-clipboard`), and registers a
`niri.desktop` session entry so display managers can offer it.

It does **not** touch `~/.config/niri/` — that directory is owned by this
repo. See the next section.

To preview without switching, dry-run with:

```sh
nix build .#homeConfigurations.quhongbin.activationPackage
```

## One-time setup: link the repo into ~/.config/niri/

```sh
./install.sh
```

That creates:

- `~/.config/niri/config.kdl` → `niri/config.kdl`
- `~/.config/niri/dms/*.kdl`   → `niri/dms/*.kdl` (one symlink per file)

Any existing real files at those paths are moved aside as `.bak`.

After this, **the repo and the live config are the same files on disk**.
That means:

- Editing `niri/config.kdl` is the same as editing `~/.config/niri/config.kdl`.
  Reload niri with `niri msg action load-config`.
- DankMaterialShell writing to `~/.config/niri/dms/colors.kdl` actually
  writes into `niri/dms/colors.kdl`, so its changes are immediately
  git-trackable. Just `git add -A && git commit`.

## Customizing

- **Username / home directory** — edit `flake.nix` (`username` and
  `homeDirectory`). Defaults to `dev` / `/home/dev`.
- **Binds / layout / outputs** — edit `niri/config.kdl`, then reload with
  `niri msg action load-config`.
- **Extra packages** — append to `home.packages` in `niri/default.nix`, then
  re-run `home-manager switch --flake .#quhongbin`.

## Initializing the GitHub repo

This repo is initialized locally with a placeholder remote. After creating the
repo on github.com (e.g. `quhongbin/niri-config`), point the remote at it:

```sh
git remote remove origin   # if a placeholder was added
git remote add origin git@github.com:quhongbin/niri-config.git
git push -u origin main
```

## Notes on the current config

`config.kdl` is mostly upstream defaults: gaps 16, focus ring enabled, border
disabled, default column widths of 1/3, 1/2, 2/3, waybar spawned at startup,
and the standard niri bind set (Mod+T alacritty, Mod+D fuzzel, Mod+Q close,
vim-style focus/move, etc.).

The active eDP-1 output block is currently commented out with `/-` — uncomment
it once you have confirmed the correct `mode` and `position` for your display
with `niri msg outputs`.
