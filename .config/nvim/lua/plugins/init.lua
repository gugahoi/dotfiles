require("vim._core.ui2").enable({})

vim.pack.add({
    { src = "https://github.com/folke/todo-comments.nvim" },
    { src = "https://github.com/saghen/blink.download" },
    {
        src = "https://github.com/saghen/blink.pairs",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/nvim-mini/mini.surround",
        version = vim.version.range("*"),
    },
})
require("todo-comments").setup()
require("blink.pairs").setup({})
require("mini.surround").setup({
    mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
    },
})

require("plugins.ai")
require("plugins.format")
require("plugins.git")
require("plugins.lsp")
require("plugins.picker")
require("plugins.theme")
require("plugins.tmux")
require("plugins.treesitter")
