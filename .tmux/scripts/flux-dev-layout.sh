#!/usr/bin/env sh
# prefix + g — recreate the Flux dev layout
#   top-left:    pnpm run dev:backend
#   bottom-left: pnpm run dev:ui:app
#   right:       idle (for opencode or whatever you spawn)
# Pass the current pane's path so the layout is cwd-relative.
cwd="$1"
top_pane=$(tmux split-window -h -b -p 35 -c "$cwd" -P -F '#{pane_id}')
bot_pane=$(tmux split-window -v    -p 50 -c "$cwd" -t "$top_pane" -P -F '#{pane_id}')
tmux send-keys -t "$top_pane" "pnpm run dev:backend" C-m
tmux send-keys -t "$bot_pane" "pnpm run dev:ui:app" C-m