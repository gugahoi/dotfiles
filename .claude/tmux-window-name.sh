#!/usr/bin/env bash
# Mirror Claude Code's session title onto the current tmux window name, and
# restore the window's original name / auto-rename behaviour when the session ends.
#
# Invoked from hooks in ~/.claude/settings.json:
#   SessionStart -> save     (record original state once, then initial sync)
#   Stop         -> sync      (re-point window name at Claude's current title)
#   SessionEnd   -> restore   (put the original name / auto-rename back)
set -u

# Only act when running inside tmux.
[ -n "${TMUX:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

pane="${TMUX_PANE:-}"
[ -n "$pane" ] || exit 0

state_dir="$HOME/.claude/.tmux-window-state"
state_file="$state_dir/${pane//\%/}"

sync_title() {
  local title
  title=$(tmux display-message -t "$pane" -p '#{pane_title}' 2>/dev/null) || return 0
  [ -n "$title" ] && tmux rename-window -t "$pane" "$title" 2>/dev/null
}

case "${1:-}" in
  save)
    mkdir -p "$state_dir"
    # Record the original name + effective automatic-rename only once per session,
    # so /clear and resume (which also fire SessionStart) don't clobber it.
    if [ ! -f "$state_file" ]; then
      name=$(tmux display-message -t "$pane" -p '#{window_name}' 2>/dev/null)
      auto=$(tmux display-message -t "$pane" -p '#{automatic-rename}' 2>/dev/null)
      printf '%s\n%s\n' "$name" "$auto" > "$state_file"
    fi
    sync_title
    ;;
  sync)
    sync_title
    ;;
  restore)
    [ -f "$state_file" ] || exit 0
    { IFS= read -r name; IFS= read -r auto; } < "$state_file"
    if [ "$auto" = "1" ]; then
      # Window name was auto-managed; re-enable so tmux recomputes it.
      tmux set-window-option -t "$pane" automatic-rename on 2>/dev/null
    else
      # Window had a pinned name; restore it and keep auto-rename off.
      tmux set-window-option -t "$pane" automatic-rename off 2>/dev/null
      tmux rename-window -t "$pane" "$name" 2>/dev/null
    fi
    rm -f "$state_file"
    ;;
esac
exit 0
