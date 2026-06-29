vim.pack.add({
    "https://github.com/sourcegraph/amp.nvim",
    "https://github.com/folke/sidekick.nvim",
})

require("amp").setup({ auto_start = true })
require("sidekick").setup({
    cli = {
        mux = {
            backend = "tmux",
            enabled = true,
        },
    },
})

-- stylua: ignore start
vim.keymap.set({"n", "t", "i", "x"}, "<c-.>", function() require("sidekick.cli").focus() end, { desc = "Sidekick Focus" })
vim.keymap.set("n", "<leader>aa", function() require("sidekick.cli").select({ filter = { installed = true } }) end, { desc = "Select CLI" })
vim.keymap.set("n", "<leader>ad", function() require("sidekick.cli").close() end, { desc = "Detach a CLI Session" })
vim.keymap.set("n", "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, { desc = "Send File" })
vim.keymap.set({"n", "x"}, "<leader>at", function() require("sidekick.cli").send({ msg = "{this}" }) end, { desc = "Send This" })
vim.keymap.set("x", "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end, { desc = "Send Visual Selection" })
vim.keymap.set({"n", "x"}, "<leader>ap", function() require("sidekick.cli").prompt() end, { desc = "Sidekick Select Prompt" })
--- Generate a conventional commit message for staged changes.
--- Outside a commit buffer: sends a prompt to the active Sidekick CLI (works with claude, opencode, pi, …).
--- Inside gitcommit/NeogitCommitMessage: runs `claude -p --model haiku` directly and inserts the
--- result at the top of the buffer. Falls back to Sidekick send if claude is not installed.
local function ai_generate_commit_msg()
  local diff = vim.fn.system("git diff --staged")
  if vim.trim(diff) == "" then
    vim.notify("No staged changes", vim.log.levels.WARN)
    return
  end
  local prompt = "Generate a conventional commit message for these staged changes. Output ONLY the commit message, no explanation:\n\n" .. diff
  local ft = vim.bo.filetype
  -- In a commit buffer we need captured output; outside we just send to the active Sidekick CLI
  if ft ~= "gitcommit" and ft ~= "NeogitCommitMessage" then
    require("sidekick.cli").send({ msg = prompt })
    return
  end
  -- ponytail: only claude supports -p one-shot stdout; opencode/pi are TUIs
  if vim.fn.executable("claude") == 0 then
    require("sidekick.cli").send({ msg = prompt })
    vim.notify("Copy the generated message from the AI pane", vim.log.levels.INFO)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  vim.notify("Generating commit message…", vim.log.levels.INFO)
  local output = {}
  vim.fn.jobstart({ "claude", "-p", prompt, "--model", "haiku" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then table.insert(output, line) end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify("Failed to generate commit message", vim.log.levels.ERROR)
        return
      end
      vim.schedule(function()
        local lines = vim.split(table.concat(output, "\n"), "\n")
        while lines[1] == "" do table.remove(lines, 1) end
        while lines[#lines] == "" do table.remove(lines) end
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
      end)
    end,
  })
end
vim.keymap.set("n", "<leader>ag", ai_generate_commit_msg, { desc = "AI: Generate commit message" })
-- stylua: ignore end

--   { "<tab>", function() -- if there is a next edit, jump to it, otherwise apply it if any if not require("sidekick").nes_jump_or_apply() then return "<Tab>" -- fallback to normal tab end end, expr = true, desc = "Goto/Apply Next Edit Suggestion", },
-- }
