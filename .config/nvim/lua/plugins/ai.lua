vim.pack.add({
    "https://github.com/sourcegraph/amp.nvim",
    "https://github.com/folke/sidekick.nvim",
})

require("amp").setup({ auto_start = true })
require("sidekick").setup({
    cli = {
        mux = {
            backend = "tmux",
            enabled = "true",
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
-- stylua: ignore end

--   { "<tab>", function() -- if there is a next edit, jump to it, otherwise apply it if any if not require("sidekick").nes_jump_or_apply() then return "<Tab>" -- fallback to normal tab end end, expr = true, desc = "Goto/Apply Next Edit Suggestion", },
-- }
