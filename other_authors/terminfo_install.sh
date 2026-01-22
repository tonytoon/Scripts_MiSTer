#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="/media/fat/terminfo"
TMPDIR="$(mktemp -d)"
SRC_URL="https://raw.githubusercontent.com/mirror/ncurses/master/misc/terminfo.src"
PROFILE_FILE="/etc/profile"
TERMINFO_LINE="export TERMINFO=${DEST_DIR}"

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "Downloading terminfo.src with wget..."
wget -qO "$TMPDIR/terminfo.src" "$SRC_URL"

echo "Compiling all terminfo entries to $DEST_DIR..."
mkdir -p "$DEST_DIR"
TERMINFO="$DEST_DIR" tic -x -o "$DEST_DIR" "$TMPDIR/terminfo.src"

echo "Ensuring TERMINFO is set in $PROFILE_FILE..."
if [ ! -f "$PROFILE_FILE" ]; then
  echo "$TERMINFO_LINE" > "$PROFILE_FILE"
elif ! grep -q "^export TERMINFO=" "$PROFILE_FILE"; then
  echo "$TERMINFO_LINE" >> "$PROFILE_FILE"
fi

echo "Done."

