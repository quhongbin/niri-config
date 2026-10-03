#!/usr/bin/env bash
# install.sh — link the repo's niri/ tree into ~/.config/niri/ as symlinks.
#
# After running this once, ~/.config/niri/config.kdl and ~/.config/niri/dms/*
# are symlinks pointing into this repo. That makes the repo the live config:
#
#   - editing repo files  →  niri (and DMS) see the change instantly
#   - DMS writing to ~/.config/niri/dms/*  →  actually writes into the repo,
#                                            so the change is git-trackable
#
# Existing real files at the target paths are moved aside as `.bak` first,
# so re-running the script is safe.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_ROOT/niri"
LIVE_DIR="${NIRI_LIVE_DIR:-$HOME/.config/niri}"

if [[ ! -d "$SRC_DIR" ]]; then
    echo "error: $SRC_DIR does not exist" >&2
    exit 1
fi

mkdir -p "$LIVE_DIR/dms"

link_one() {
    local rel="$1"
    local src="$SRC_DIR/$rel"
    local dst="$LIVE_DIR/$rel"

    if [[ ! -e "$src" ]]; then
        echo "skipped (missing in repo): $rel"
        return
    fi

    # If the destination is already the right symlink, nothing to do.
    if [[ -L "$dst" ]] && [[ "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        echo "ok (already linked): $rel"
        return
    fi

    # If the destination is a real file/dir, move it aside.
    if [[ -e "$dst" ]]; then
        echo "backing up: $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -s "$src" "$dst"
    echo "linked: $dst → $src"
}

echo "Repo:  $SRC_DIR"
echo "Live:  $LIVE_DIR"
echo

link_one "config.kdl"

if [[ -d "$SRC_DIR/dms" ]]; then
    for f in "$SRC_DIR/dms/"*.kdl; do
        [[ -e "$f" ]] || continue
        link_one "dms/$(basename "$f")"
    done
fi

echo
echo "Done. ~/.config/niri/ is now backed by this repo."
echo "Reload niri with:  niri msg action load-config"
