-- Rex port of ~/.tmux.conf. Apply with `rex config reload`.
local P = "ctrl+a>" -- tmux prefix
local shell = "com.superlogical.terminal.shell"

rex.bind(P .. "ctrl+a", "pane.send_key", { key = "ctrl+a" }) -- send-prefix
rex.bind(P .. "r", "client.config.reload")

-- Windows (Rex tabs). Tabs are already numbered from 1.
rex.bind(P .. "c", "client.tab.new")
rex.bind(P .. "n", "client.tab.next")
rex.bind(P .. "p", "client.tab.previous")
rex.bind(P .. ",", "client.tab.rename")
rex.bind(P .. "shift+7", "client.tab.close") -- &
for i = 1, 9 do
  rex.bind(P .. i, "client.tab.goto", { index = i })
end

-- Panes. " and % on a US layout.
rex.bind(P .. "shift+'", "pane.split", { direction = "down" })
rex.bind(P .. "shift+5", "pane.split", { direction = "right" })
rex.bind(P .. "x", "pane.close")
rex.bind(P .. "z", "pane.zoom")
rex.bind(P .. "shift+=", "pane.zoom") -- +
rex.bind("alt+z", "pane.zoom")
rex.bind(P .. "shift+1", "pane.move_to_new_tab") -- ! break-pane
rex.bind(P .. "shift+b", "pane.move_to_tab") -- B: picker, doesn't restore the exact layout
rex.bind(P .. "\\", "pane.balance") -- nearest thing to select-layout
rex.bind(P .. "shift+h", "pane.resize", { direction = "left" })
rex.bind(P .. "shift+j", "pane.resize", { direction = "down" })
rex.bind(P .. "shift+k", "pane.resize", { direction = "up" })
rex.bind(P .. "shift+l", "pane.resize", { direction = "right" })

-- Sessions: Rex's own picker. alt+f (rex-sesh) is bound below, after `popup`.
rex.bind(P .. "s", "session.switch")

-- vim-tmux-navigator: ctrl+hjkl goes to the program when it's vim-like,
-- otherwise moves between Rex panes.
local vim_like = { vim = true, nvim = true, view = true, vimdiff = true, nvimdiff = true, fzf = true, cliamp = true }
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    local p = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    if p and p.foreground and vim_like[p.foreground.name] then
      return false
    end
    rex.session.focus_direction({ session_id = ctx.session_id, direction = dir, wrap = true })
    return true
  end)
end

-- display-popup -E: a floating pane, in the focused pane's directory, that closes when its command
-- exits. There's no status line to show errors on, so a failure (but not Ctrl-C) waits for Enter.
-- The command's shell isn't interactive, so it misses .zshrc's ~/.local/bin (wt, rex-sesh).
local keep_failures = [["$@"; s=$?; [ $s = 0 ] || [ $s = 130 ] || { printf '\n[exit %d] Press Enter to close' $s; read -r _; }]]
rex.action({
  name = "popup",
  title = "Popup",
  args = { cmd = "array" },
  run = function(ctx, args)
    local p = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    local _, err = rex.session.new_layer({
      bounds = { 0.1, 0.15, 0.8, 0.7 },
      focus = true,
      layout = rex.layout.block({ flavor = shell, options = {
        cwd = p and p.foreground and p.foreground.cwd or nil,
        path_prepend = { os.getenv("HOME") .. "/.local/bin" },
        command = { "sh", "-c", keep_failures, "sh", unpack(args.cmd) },
      } }),
    })
    if err then error(err, 0) end
  end,
})
rex.bind("alt+f", "popup", { cmd = { "rex-sesh" } }) -- ~/.local/bin/rex-sesh
-- tmux's M-g/M-i: wt opens the picked worktree in its own Rex session.
rex.bind("alt+g", "popup", { cmd = { "wt" } })
rex.bind("alt+i", "popup", { cmd = { "wt", "issue" } })

-- prefix e: open this pane's scrollback in $EDITOR, in a new tab.
rex.action({
  name = "scrollback_in_editor",
  title = "Open Scrollback in Editor",
  run = function(ctx)
    local _, err = rex.session.new_window({
      layout = rex.layout.block({
        flavor = shell,
        options = {
          command = {
            "sh", "-c",
            'f=$(mktemp) && rex capture -s "$1" -b "$2" --trim > "$f" && exec "${EDITOR:-nvim}" "$f"',
            "sh", ctx.session_id, ctx.block_id,
          },
        },
      }),
    })
    if err then error(err, 0) end
  end,
})
rex.bind(P .. "e", "scrollback_in_editor")

-- prefix O: outstanding-work panel on the right.
rex.action({
  name = "outstanding_work",
  title = "Outstanding Work Panel",
  run = function(ctx)
    local _, err = rex.session.new_split({
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      ratio = 0.6,
      layout = rex.layout.block({
        flavor = shell,
        options = {
          cwd = os.getenv("HOME") .. "/Projects/outstanding-work/main",
          command = { "pnpm", "start", "--panel" },
        },
      }),
    })
    if err then error(err, 0) end
  end,
})
rex.bind(P .. "shift+o", "outstanding_work")
