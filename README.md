# claude-statusline

Статусная строка для [Claude Code](https://code.claude.com/docs/en/statusline): аккаунт, модель, effort, имя сессии, рабочая папка, лимиты использования и заполненность контекста.

```
Aleksei (pro) │ Opus 5.5 (high) │ Статусная строка │ …ents/github/local_marketplace │ usage: 4:10 24% · w 3% │ ctx 8%
```

| Блок | Что показывает | Откуда |
|---|---|---|
| `Aleksei (pro)` | имя аккаунта и тариф | `~/.claude.json` -> `oauthAccount.displayName`, `organizationType` |
| `Opus 5.5 (high)` | модель и effort | `model.display_name`, `effort.level` |
| `Статусная строка` | имя сессии (автоматическое или из `/rename`) | `session_name` |
| `…ents/github/local_marketplace` | текущая папка, не длиннее 30 символов | `workspace.current_dir` |
| `usage: 4:10 24%` | 5-часовой лимит: время до сброса (Ч:ММ) и процент | `rate_limits.five_hour` |
| `w 3%` | недельный лимит | `rate_limits.seven_day` |
| `ctx 8%` | заполненность контекстного окна | `context_window.used_percentage` |

Проценты подсвечиваются: зелёный < 50%, жёлтый < 80%, красный >= 80%.

## Требования

- Claude Code с поддержкой `statusLine` (проверено на 2.1.319)
- `bash`, `jq` (`brew install jq` / `apt install jq`)
- Лимиты (`usage`, `w`) приходят только при входе по подписке Pro/Max и после первого ответа модели — до этого на их месте `-`

## Установка

### Одной командой

```bash
curl -fsSL https://raw.githubusercontent.com/chlp/claude-statusline/main/install.sh | bash
```

Скрипт кладёт `statusline.sh` в `~/.claude/` и прописывает `statusLine` в `~/.claude/settings.json`, сохранив бэкап в `~/.claude/settings.json.bak-statusline`.

### Вручную

1. Скачай скрипт и сделай его исполняемым:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/chlp/claude-statusline/main/statusline.sh -o ~/.claude/statusline.sh
   chmod +x ~/.claude/statusline.sh
   ```

2. Добавь в `~/.claude/settings.json`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.claude/statusline.sh",
       "padding": 0
     }
   }
   ```

3. Строка появится после следующего ответа Claude. Если нет — перезапусти Claude Code.

Чтобы строка была только в одном проекте, положи тот же блок в `.claude/settings.json` этого проекта вместо глобального.

## Проверка без Claude Code

```bash
echo '{"model":{"display_name":"Opus 5.5"},"effort":{"level":"high"},"workspace":{"current_dir":"'"$HOME"'/projects/demo"},"rate_limits":{"five_hour":{"used_percentage":24,"resets_at":'$(( $(date +%s) + 15000 ))'},"seven_day":{"used_percentage":3}},"context_window":{"used_percentage":8}}' \
  | ~/.claude/statusline.sh; echo
```

## Удаление

```bash
jq 'del(.statusLine)' ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
rm ~/.claude/statusline.sh
```

## Настройка

Всё в одном файле `statusline.sh`: порядок блоков, цвета (`\033[35m` и т. п.), лимит длины пути (`30`), пороги подсветки (`50`/`80`). Полный список полей, которые Claude Code передаёт на stdin, — в [документации](https://code.claude.com/docs/en/statusline).

## Лицензия

MIT
