#!/usr/bin/env bash
# sync-from-system.sh — copy live files from ~/.config/niri/ back into the repo.
#
# Use this when you (or a tool like DankMaterialShell) edit files in the live
# config dir and you want to capture those changes into git. The workflow is:
#
#   1. Edit ~/.config/niri/  (either by hand, or by DMS regenerating dms/)
#   2. ./sync-from-system.sh
#   3. git diff                          # review what changed
#   4. git add -A && git commit
#
# Without this script, the repo → ~/.config/niri/ direction is one-way:
# home-manager will overwrite your live edits on the next switch.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIVE_DIR="${NIRI_LIVE_DIR:-$HOME/.config/niri}"

if [[ ! -d "$LIVE_DIR" ]]; then
    echo "error: $LIVE_DIR does not exist" >&2
    exit 1
fi

copy_one() {
    local rel="$1"
    if [[ -e "$LIVE_DIR/$rel" ]]; then
        mkdir -p "$REPO_ROOT/niri/$(dirname "$rel")"
        cp "$LIVE_DIR/$rel" "$REPO_ROOT/niri/$rel"
        echo "synced: niri/$rel"
    else
        echo "skipped (not present live): $rel"
    fi
}

copy_one config.kdl

# Pull every dms/ fragment that DMS writes, but don't fail if a file is
# missing — the live set may not match the repo's snapshot one-for-one.
if [[ -d "$LIVE_DIR/dms" ]]; then
    for f in "$LIVE_DIR/dms/"*.kdl; do
        [[ -e "$f" ]] || continue
        rel="dms/$(basename "$f")"
        copy_one "$rel"
    done
else
    echo "skipped: $LIVE_DIR/dms/ does not exist"
fi

echo
echo "Done. Review with: git diff"
