vim.pack.add({
    "https://github.com/lewis6991/gitsigns.nvim",

    -- Neogit deps
    "https://github.com/NeogitOrg/neogit",
    "https://github.com/nvim-lua/plenary.nvim", -- required
    "https://github.com/esmuellert/codediff.nvim", -- optional
})

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit kind=floating<cr>")
