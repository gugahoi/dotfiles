# Working with me

- **Delegating:** when I ask to delegate, spin off or hand off work, launch the session yourself. In the desktop app, start a linked session. In tmux, create the worktree, then run `tmux new-window -c <worktree> "claude '<brief>'"`. I want a running session, not a prompt to paste.
- **Plan docs:** once a plan, epic or ticket draft exists, it is the single source of truth. Write each decision into it as soon as we settle it.
- **Timeouts:** this Mac has no GNU `timeout`. Bound a command with the Bash tool's `timeout` parameter, or `gtimeout` if coreutils is installed.
