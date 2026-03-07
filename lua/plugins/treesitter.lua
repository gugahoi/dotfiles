-- Add treesitter plugin
vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		data = {
			on_update = function()
				vim.cmd("TSUpdate")
			end,
		},
	},
})

-- local ok, ts = pcall(require, "nvim-treesitter")
local ok, _ = pcall(require, "nvim-treesitter")
if not ok then
	return
end

-- This is disabled as it seems to be called during every startup. Not sure how
-- to resolve for now
-- local ensure_installed = { "go", "typescript", "lua", "javascript", "json" }
--
-- local already_installed = ts.get_installed()
--
-- local to_install = vim.iter(ensure_installed)
-- 	:filter(function(parser)
-- 		return not vim.tbl_contains(already_installed, parser)
-- 	end)
-- 	:totable()
--
-- if #to_install > 0 then
-- 	ts.install(to_install)
-- end

-- Folds
vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldmethod = "expr"

-- Indentation [experimental]
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
	desc = "Try to enable tree-sitter syntax highlighting",
	pattern = "*", -- run on *all* filetypes
	callback = function()
		pcall(function()
			vim.treesitter.start()
		end)
	end,
})
