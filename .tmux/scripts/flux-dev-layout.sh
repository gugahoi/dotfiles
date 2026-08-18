#!/usr/bin/env sh
# prefix + g — recreate the Flux dev layout
#   top-left:    pnpm run dev:backend
#   bottom-left: pnpm run dev:ui:app
#   right:       idle (for opencode or whatever you spawn)
# Pass the current pane's path; panes open at the repo root so this works from
# any subfolder (falls back to the given path when not in a git repo).
cwd=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null || echo "$1")
top_pane=$(tmux split-window -h -b -p 35 -c "$cwd" -P -F '#{pane_id}')
bot_pane=$(tmux split-window -v    -p 50 -c "$cwd" -t "$top_pane" -P -F '#{pane_id}')
# No deps? install once in the top pane; the bottom pane waits on a tmux channel
# so both dev commands don't race a half-installed node_modules.
if [ -d "$cwd/node_modules" ]; then
	pre_top=''
	pre_bot=''
else
	pre_top='pnpm install; tmux wait-for -S flux-deps; '
	pre_bot='tmux wait-for flux-deps; '
fi

tmux send-keys -t "$top_pane" "${pre_top}pnpm run dev:backend" C-m
tmux send-keys -t "$bot_pane" "${pre_bot}pnpm run dev:ui:app" C-m