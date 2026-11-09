#!/usr/bin/env bash
# Статуслайн Claude Code: модель · effort · имя сессии · папка · 5h/7d usage · контекст.
# JSON приходит на stdin (поля: model, effort, session_name, workspace, rate_limits, context_window).
input=$(cat)

j() { jq -r "$1 // empty" <<<"$input"; }

model=$(j '.model.display_name')
effort=$(j '.effort.level')
name=$(j '.session_name')
dir=$(j '.workspace.current_dir')
dir=${dir/#$HOME/\~}
# Не длиннее 30 символов: хвост пути с «…» в начале.
[ ${#dir} -gt 30 ] && dir="…${dir: -29}"
five=$(j '.rate_limits.five_hour.used_percentage | numbers | floor')
five_reset=$(j '.rate_limits.five_hour.resets_at | numbers | floor')
week=$(j '.rate_limits.seven_day.used_percentage | numbers | floor')
ctx=$(j '.context_window.used_percentage | numbers | floor')

# Цвет по проценту: зелёный < 50, жёлтый < 80, красный >= 80.
pct() {
  local v=$1 c
  [ -z "$v" ] && { printf -- '-'; return; }
  if   [ "$v" -ge 80 ]; then c=31
  elif [ "$v" -ge 50 ]; then c=33
  else c=32; fi
  printf '\033[%sm%s%%\033[0m' "$c" "$v"
}

dim=$'\033[2m'; rst=$'\033[0m'; bold=$'\033[1m'
sep=" ${dim}│${rst} "

# Аккаунт из ~/.claude.json: displayName + тариф (claude_pro -> pro, claude_max -> max).
acct=$(jq -r '.oauthAccount // empty
  | (.displayName // "") + "\t" + ((.organizationType // "") | sub("^claude_"; ""))' \
  ~/.claude.json 2>/dev/null)
IFS=$'\t' read -r user plan <<<"$acct"

out=""
if [ -n "$user" ]; then
  out+="\033[35m${user}${rst}"
  [ -n "$plan" ] && out+=" ${dim}(${plan})${rst}"
  out+="${sep}"
fi
out+="${bold}${model}${rst}"
[ -n "$effort" ] && out+=" ${dim}(${effort})${rst}"
[ -n "$name" ]   && out+="${sep}\033[36m${name}${rst}"
out+="${sep}${dir}"
# Время до сброса 5-часового лимита в формате Ч:ММ (resets_at — unix-секунды).
left=""
if [ -n "$five_reset" ]; then
  s=$(( five_reset - $(date +%s) ))
  [ "$s" -lt 0 ] && s=0
  left=$(printf '%d:%02d ' $(( s / 3600 )) $(( s % 3600 / 60 )))
fi

out+="${sep}usage: ${left}$(pct "$five") ${dim}·${rst} w $(pct "$week")"
out+="${sep}ctx $(pct "$ctx")"

printf '%b' "$out"
