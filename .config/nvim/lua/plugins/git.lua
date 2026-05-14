vim.pack.add({
    "https://github.com/lewis6991/gitsigns.nvim",

    -- Neogit deps
    "https://github.com/NeogitOrg/neogit",
    "https://github.com/esmuellert/codediff.nvim", -- optional
})

require("gitsigns").setup()

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>")
