vim.pack.add({
	"https://github.com/folke/todo-comments.nvim",
})
require("todo-comments").setup()

require("plugins.amp")
require("plugins.format")
require("plugins.git")
require("plugins.lsp")
require("plugins.snacks")
require("plugins.theme")
require("plugins.tmux")
require("plugins.treesitter")
