#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="/media/fat/terminfo"
TMPDIR="$(mktemp -d)"
SRC_URL="https://raw.githubusercontent.com/mirror/ncurses/master/misc/terminfo.src"
PROFILE_FILE="/etc/profile"
TERMINFO_LINE="export TERMINFO=${DEST_DIR}"
CACHE_SHA="${DEST_DIR}/.terminfo.src.sha256"

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

mkdir -p "$DEST_DIR"

echo "Downloading terminfo.src with wget..."
wget -qO "$TMPDIR/terminfo.src" "$SRC_URL"

NEW_SHA="$(sha256sum "$TMPDIR/terminfo.src" | awk '{print $1}')"
OLD_SHA=""
if [ -f "$CACHE_SHA" ]; then
  OLD_SHA="$(cat "$CACHE_SHA")"
fi

if [ "$NEW_SHA" = "$OLD_SHA" ]; then
  echo "terminfo.src unchanged; skipping compile."
else
  echo "Compiling all terminfo entries to $DEST_DIR..."
  TERMINFO="$DEST_DIR" tic -x -o "$DEST_DIR" "$TMPDIR/terminfo.src"
  echo "$NEW_SHA" > "$CACHE_SHA"
fi

echo "Ensuring TERMINFO is set in $PROFILE_FILE..."
if [ ! -f "$PROFILE_FILE" ]; then
  echo "$TERMINFO_LINE" > "$PROFILE_FILE"
elif ! grep -q "^export TERMINFO=" "$PROFILE_FILE"; then
  echo "$TERMINFO_LINE" >> "$PROFILE_FILE"
fi

echo "Done."

