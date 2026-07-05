local o = vim.o
o.backup = false
o.breakindent = true
o.cmdheight = 0
o.colorcolumn = "81"
o.cursorline = true
o.expandtab = true
o.ignorecase = true
o.inccommand = "split"
o.number = true
o.pumborder = "rounded"
o.relativenumber = true
o.scrolloff = 10
o.shiftwidth = 4
o.showmode = false
o.signcolumn = "yes"
o.smartcase = true
o.smartindent = true
o.softtabstop = 4
o.splitbelow = true
o.splitright = true
o.swapfile = false
o.tabstop = 4
o.termguicolors = true
o.undodir = vim.fn.stdpath("data") .. "/undodir"
o.undofile = true
o.updatetime = 250
o.winborder = "rounded"
o.wrap = false

vim.g.netrw_banner = 0

vim.o.list = true
-- o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    callback = function()
        vim.hl.on_yank()
    end,
})
