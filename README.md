# claude-statusline

A status line for [Claude Code](https://code.claude.com/docs/en/statusline): account, model, effort, session name, working directory, usage limits and context window fill.

```
Aleksei (pro) │ Opus 5.5 (high) │ Status line setup │ claude-statusline │ usage: 4:10 24% · w 3% │ ctx 8%
```

| Block | What it shows | Source |
|---|---|---|
| `Aleksei (pro)` | account name and plan | `~/.claude.json` -> `oauthAccount.displayName`, `organizationType` |
| `Opus 5.5 (high)` | model and effort | `model.display_name`, `effort.level` |
| `Status line setup` | session name (auto-generated or set via `/rename`) | `session_name` |
| `claude-statusline` | current directory, at most 30 characters (longer paths keep the tail: `…ents/github/my-project`) | `workspace.current_dir` |
| `usage: 4:10 24%` | 5-hour limit: time until reset (H:MM) and percent used | `rate_limits.five_hour` |
| `w 3%` | weekly limit | `rate_limits.seven_day` |
| `ctx 8%` | context window fill | `context_window.used_percentage` |

Percentages are colored: green < 50%, yellow < 80%, red >= 80%.

## Requirements

- Claude Code with `statusLine` support (tested on 2.1.319)
- `bash`, `jq` (`brew install jq` / `apt install jq`)
- Limits (`usage`, `w`) are only provided for Pro/Max subscription logins and only after the first model response; until then they show as `-`

## Installation

### One command

```bash
curl -fsSL https://raw.githubusercontent.com/chlp/claude-statusline/main/install.sh | bash
```

The installer puts `statusline.sh` into `~/.claude/` and adds `statusLine` to `~/.claude/settings.json`, keeping a backup at `~/.claude/settings.json.bak-statusline`.

### Manually

1. Download the script and make it executable:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/chlp/claude-statusline/main/statusline.sh -o ~/.claude/statusline.sh
   chmod +x ~/.claude/statusline.sh
   ```

2. Add to `~/.claude/settings.json`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.claude/statusline.sh",
       "padding": 0
     }
   }
   ```

3. The line appears after Claude's next response. If it doesn't, restart Claude Code.

To enable it for a single project only, put the same block into that project's `.claude/settings.json` instead of the global one.

## Testing without Claude Code

```bash
echo '{"model":{"display_name":"Opus 5.5"},"effort":{"level":"high"},"workspace":{"current_dir":"'"$HOME"'/projects/demo"},"rate_limits":{"five_hour":{"used_percentage":24,"resets_at":'$(( $(date +%s) + 15000 ))'},"seven_day":{"used_percentage":3}},"context_window":{"used_percentage":8}}' \
  | ~/.claude/statusline.sh; echo
```

## Uninstall

```bash
jq 'del(.statusLine)' ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
rm ~/.claude/statusline.sh
```

## Customization

Everything lives in a single file, `statusline.sh`: block order, colors (`\033[35m` etc.), path length limit (`30`), color thresholds (`50`/`80`). The full list of fields Claude Code sends on stdin is in the [documentation](https://code.claude.com/docs/en/statusline).

## License

MIT
