-- In this file, we can find all the global key maps for Neovim
--Diable highlight on <esc>
vim.api.nvim_set_keymap('n', '<esc>', ':noh<return><esc>', { noremap = true, silent = true })

--Remap ; to :
vim.keymap.set('n', ';', ':')

--Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Remap for capital letter commands for shift holders
-- TODO: not sure how to do this in lua
vim.cmd [[cnoreabbrev W! w!]]
vim.cmd [[cnoreabbrev Q! q!]]
vim.cmd [[cnoreabbrev Qall! qall!]]
vim.cmd [[cnoreabbrev Wq wq]]
vim.cmd [[cnoreabbrev Wa wa]]
vim.cmd [[cnoreabbrev wQ wq]]
vim.cmd [[cnoreabbrev WQ wq]]
vim.cmd [[cnoreabbrev W w]]
vim.cmd [[cnoreabbrev Q q]]
vim.cmd [[cnoreabbrev Qall qall]]

-- Telescope mappings
local builtin = require('telescope/builtin')
vim.keymap.set('n', '<leader><space>', function()
  builtin.buffers { sort_mru = true, ignore_current_buffer = true }
end)
vim.keymap.set('n', '<leader>b', builtin.buffers)
vim.keymap.set('n', '<leader>f', builtin.find_files)
vim.keymap.set('n', '<leader>g', builtin.git_files)
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>y', builtin.command_history)
vim.keymap.set('n', '<leader>c', builtin.commands)
vim.keymap.set('n', '<leader>c', builtin.commands)
vim.keymap.set('n', '<leader>sh', builtin.help_tags)
vim.keymap.set('n', '<leader>sd', builtin.grep_string)
vim.keymap.set('n', '<leader>r', builtin.live_grep)
vim.keymap.set('n', '<leader>?', builtin.oldfiles)

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Create directories on Save
-- source: https://vi.stackexchange.com/a/679
vim.cmd [[
augroup Mkdir
  autocmd!
  autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END
]]
