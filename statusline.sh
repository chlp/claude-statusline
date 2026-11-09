#!/usr/bin/env bash
# Claude Code status line: account · model · effort · session name · cwd · 5h/weekly usage · context.
# Claude Code sends JSON on stdin (fields: model, effort, session_name, workspace, rate_limits, context_window).
input=$(cat)

j() { jq -r "$1 // empty" <<<"$input"; }

model=$(j '.model.display_name')
effort=$(j '.effort.level')
name=$(j '.session_name')
dir=$(j '.workspace.current_dir')
dir=${dir/#$HOME/\~}
# At most 30 characters: keep the tail of the path, prefixed with "…".
[ ${#dir} -gt 30 ] && dir="…${dir: -29}"
five=$(j '.rate_limits.five_hour.used_percentage | numbers | floor')
five_reset=$(j '.rate_limits.five_hour.resets_at | numbers | floor')
week=$(j '.rate_limits.seven_day.used_percentage | numbers | floor')
ctx=$(j '.context_window.used_percentage | numbers | floor')

# Color by percent: green < 50, yellow < 80, red >= 80.
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

# Account from ~/.claude.json: displayName + plan (claude_pro -> pro, claude_max -> max).
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
# Time until the 5-hour limit resets, as H:MM (resets_at is unix seconds).
left=""
if [ -n "$five_reset" ]; then
  s=$(( five_reset - $(date +%s) ))
  [ "$s" -lt 0 ] && s=0
  left=$(printf '%d:%02d ' $(( s / 3600 )) $(( s % 3600 / 60 )))
fi

out+="${sep}usage: ${left}$(pct "$five") ${dim}·${rst} w $(pct "$week")"
out+="${sep}ctx $(pct "$ctx")"

printf '%b' "$out"
