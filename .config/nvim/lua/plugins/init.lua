vim.pack.add({
    "https://github.com/folke/todo-comments.nvim",
    "https://github.com/saghen/blink.download",
    {
        src = "https://github.com/saghen/blink.pairs",
        version = vim.version.range("*"),
    },
})
require("todo-comments").setup()
require("blink.pairs").setup({})

require("plugins.ai")
require("plugins.format")
require("plugins.git")
require("plugins.lsp")
require("plugins.picker")
require("plugins.theme")
require("plugins.tmux")
require("plugins.treesitter")
