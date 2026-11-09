#!/usr/bin/env bash
# Устанавливает статусную строку для Claude Code:
#   1) кладёт statusline.sh в ~/.claude/
#   2) прописывает statusLine в ~/.claude/settings.json (с бэкапом)
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/chlp/claude-statusline/main"
DIR="$HOME/.claude"
SCRIPT="$DIR/statusline.sh"
SETTINGS="$DIR/settings.json"

command -v jq >/dev/null || { echo "Нужен jq: brew install jq (macOS) или apt install jq" >&2; exit 1; }

mkdir -p "$DIR"

# Если запущено из клона репозитория — берём локальный файл, иначе качаем.
here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "$here" ] && [ -f "$here/statusline.sh" ]; then
  cp "$here/statusline.sh" "$SCRIPT"
else
  curl -fsSL "$REPO_RAW/statusline.sh" -o "$SCRIPT"
fi
chmod +x "$SCRIPT"
echo "Скрипт: $SCRIPT"

[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak-statusline"
tmp="$(mktemp)"
jq '.statusLine = {"type":"command","command":"~/.claude/statusline.sh","padding":0}' "$SETTINGS" > "$tmp"
mv "$tmp" "$SETTINGS"
echo "Настройки: $SETTINGS (бэкап: $SETTINGS.bak-statusline)"
echo "Готово. Строка появится после следующего ответа Claude (или перезапусти Claude Code)."
