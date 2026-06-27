#!/usr/bin/env bash
# Claude Code notifications. Invoked from hooks with the event name:
#   notify.sh notification   (Claude needs input/permission)
#   notify.sh stop           (response finished)
# Reads the hook JSON on stdin. Three behaviours:
#   1. suppress when you're already looking at this session
#   2. on stop, show the last assistant line instead of "Response ready"
#   3. clicking the notification jumps to the tmux window that fired it
set -u

input=$(cat)
event="${1:-stop}"
pane="${TMUX_PANE:-}"

# 1. Skip if Ghostty is frontmost AND (not in tmux, or this window is active).
front=$(lsappinfo info -only bundleid "$(lsappinfo front 2>/dev/null)" 2>/dev/null)
case "$front" in
  *com.mitchellh.ghostty*)
    if [ -z "$pane" ]; then
      exit 0
    elif [ "$(tmux display-message -t "$pane" -p '#{window_active}' 2>/dev/null)" = "1" ]; then
      exit 0
    fi
    ;;
esac

dir=$(basename "$PWD")
# Append the git branch so concurrent worktrees are distinguishable.
branch=$(git -C "$PWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -n "$branch" ] && [ "$branch" != "HEAD" ] && dir="$dir · $branch"

# Permission/input prompts pierce Do Not Disturb; routine "done" pings respect it.
dnd=""
if [ "$event" = "notification" ]; then
  msg=$(printf '%s' "$input" | jq -r '.message // "Waiting for your input"')
  dnd="-ignoreDnD"
else
  # 2. Last assistant text block from the transcript tail.
  transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
  msg=""
  if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    msg=$(tail -n 200 "$transcript" \
      | jq -rs '[.[] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text] | last // empty' 2>/dev/null \
      | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-140)
  fi
  [ -n "$msg" ] || msg="Response ready"
fi

# 3. Click -> focus Ghostty and select the firing window/pane.
if [ -n "$pane" ]; then
  execute="open -b com.mitchellh.ghostty; tmux select-window -t '$pane'; tmux select-pane -t '$pane'"
else
  execute="open -b com.mitchellh.ghostty"
fi

terminal-notifier -title 'Claude Code' -subtitle "$dir" -message "$msg" \
  -group claude-code -sound Glass -execute "$execute" $dnd
