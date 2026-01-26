#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DEST="$HOME/Obsidian/Main/.obsidian/snippets"

cd "$PROJECT_DIR"

echo "Installing CSS snippets to $DEST..."
mkdir -p "$DEST"

# Copy all CSS files
for css in *.css; do
  if [ -f "$css" ]; then
    cp "$css" "$DEST/"
    echo "  ✓ $css"
  fi
done

echo ""
echo "✓ Installed CSS snippets. Enable them in Obsidian Settings > Appearance > CSS snippets."
