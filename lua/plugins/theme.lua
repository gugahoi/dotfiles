vim.pack.add({ "https://github.com/scottmckendry/cyberdream.nvim" })

require("cyberdream").setup({
	-- Set light or dark variant
	variant = "default", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`

	-- Enable transparent background
	transparent = true,
})

vim.cmd("colorscheme cyberdream")
