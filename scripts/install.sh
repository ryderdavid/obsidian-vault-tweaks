#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VAULT="$1"
if [ -z "$VAULT" ]; then
  echo "Usage: $0 <vault-path>"
  exit 1
fi

cd "$PROJECT_DIR"

# --- CSS Snippets ---
SNIPPETS_DEST="$VAULT/.obsidian/snippets"
echo "Installing CSS snippets to $SNIPPETS_DEST..."
mkdir -p "$SNIPPETS_DEST"

for css in css/*.css; do
  if [ -f "$css" ]; then
    cp "$css" "$SNIPPETS_DEST/"
    echo "  + $(basename "$css")"
  fi
done

# Archived snippets are not installed (remove stale copies from vault)
for css in css/archived/*.css; do
  if [ -f "$css" ]; then
    target="$SNIPPETS_DEST/$(basename "$css")"
    if [ -f "$target" ]; then
      rm "$target"
      echo "  - $(basename "$css") (archived, removed from vault)"
    fi
  fi
done

# --- Templater Templates ---
TEMPLATES_DEST="$VAULT/Resources/Templates"
echo ""
echo "Installing templates to $TEMPLATES_DEST..."
mkdir -p "$TEMPLATES_DEST"

for tmpl in templates/*.md; do
  if [ -f "$tmpl" ]; then
    cp "$tmpl" "$TEMPLATES_DEST/"
    echo "  + $(basename "$tmpl")"
  fi
done

echo ""
echo "Done."
