#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="/media/fat/terminfo"
PROFILE_FILE="/etc/profile"

echo "Removing terminfo directory: $DEST_DIR"
rm -rf "$DEST_DIR"

echo "Removing TERMINFO export from $PROFILE_FILE (if present)..."
if [ -f "$PROFILE_FILE" ]; then
  sed -i '/^export TERMINFO=\/media\/fat\/terminfo$/d' "$PROFILE_FILE"
fi

echo "Done."

