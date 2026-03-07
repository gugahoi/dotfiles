vim.pack.add({ "https://github.com/folke/snacks.nvim" })
local Snacks = require("snacks")

Snacks.setup({
	explorer = { replace_netrw = true, enabled = true },
	notifier = { enabled = true },
	picker = {
		sources = {
			explorer = {},
			files = { hidden = true },
			grep = {},
		},
	},
})

local keymaps = {
    -- stylua: ignore start
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },

    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    { "<leader>sm", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>s\"", function() Snacks.picker.registers() end, desc = "Registers" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Neovim Help" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "Document Symbols" },
	-- stylua: ignore end
}

for _, map in ipairs(keymaps) do
	local opts = { desc = map.desc }
	if map.silent ~= nil then
		opts.silent = map.silent
	end
	if map.noremap ~= nil then
		opts.noremap = map.noremap
	else
		opts.noremap = true
	end
	if map.expr ~= nil then
		opts.expr = map.expr
	end

	local mode = map.mode or "n"
	vim.keymap.set(mode, map[1], map[2], opts)
end
