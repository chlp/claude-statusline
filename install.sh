#!/usr/bin/env bash
# Installs the Claude Code status line:
#   1) puts statusline.sh into ~/.claude/
#   2) adds statusLine to ~/.claude/settings.json (with a backup)
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/chlp/claude-statusline/main"
DIR="$HOME/.claude"
SCRIPT="$DIR/statusline.sh"
SETTINGS="$DIR/settings.json"

command -v jq >/dev/null || { echo "jq is required: brew install jq (macOS) or apt install jq" >&2; exit 1; }

mkdir -p "$DIR"

# When run from a clone, use the local file; otherwise download it.
here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "$here" ] && [ -f "$here/statusline.sh" ]; then
  cp "$here/statusline.sh" "$SCRIPT"
else
  curl -fsSL "$REPO_RAW/statusline.sh" -o "$SCRIPT"
fi
chmod +x "$SCRIPT"
echo "Script: $SCRIPT"

[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak-statusline"
tmp="$(mktemp)"
jq '.statusLine = {"type":"command","command":"~/.claude/statusline.sh","padding":0}' "$SETTINGS" > "$tmp"
mv "$tmp" "$SETTINGS"
echo "Settings: $SETTINGS (backup: $SETTINGS.bak-statusline)"
echo "Done. The status line appears after Claude's next response (or restart Claude Code)."
