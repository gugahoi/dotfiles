-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

-- local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
-- vim.api.nvim_create_autocmd('BufWritePost',
--   { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager
  use 'tpope/vim-fugitive' -- Git commands in nvim
  use 'tpope/vim-rhubarb' -- Fugitive-companion to interact with github
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-frecency.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use { 'nvim-telescope/telescope-frecency.nvim', requires = { "tami5/sqlite.lua" } }
  -- use 'mjlbach/onedark.nvim' -- Theme inspired by Atom
  use "projekt0n/github-nvim-theme" -- github inspired theme
  use 'nvim-lualine/lualine.nvim' -- Fancier statusline
  -- Add indentation guides even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'
  -- Add git related info in the signs columns and popups
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'windwp/nvim-ts-autotag'

  -- typescript helpers (Rename file, imports, etc...)
  use { 'jose-elias-alvarez/nvim-lsp-ts-utils', requires = { 'nvim-lua/plenary.nvim' } }
  use "williamboman/nvim-lsp-installer" -- UI for LSP servers in neovim
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client

  -- cmp and plugins
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-cmdline'
  use 'petertriho/cmp-git'
  use 'saadparwaiz1/cmp_luasnip'
  use 'hrsh7th/nvim-cmp'
  use { "zbirenbaum/copilot-cmp", module = "copilot_cmp" }

  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use 'rafamadriz/friendly-snippets'
  use 'jose-elias-alvarez/null-ls.nvim' -- Useful for running prettier on save
  use 'norcalli/nvim-colorizer.lua' -- show colors (hex/name) to vim
  use 'ray-x/lsp_signature.nvim' -- show functions signature help
  use 'machakann/vim-sandwich' -- edit surroundings of a textobject (',",{,[,...
  use 'windwp/nvim-autopairs' --
  use 'https://gitlab.com/yorickpeterse/nvim-pqf.git' -- pretty quickfix
  use 'github/copilot.vim'
end)

require('config.opts')
require('config.mappings')
require('config.telescope')
require('config.treesitter')
require('config.lsp')
require('config.cmp')
require('config.null_ls')
require('config.sandwich')

require('Comment').setup()
require('pqf').setup()
require('github-theme').setup({ theme_style = 'dark_default' })
require 'colorizer'.setup({ css = { css = true } })
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'onedark',
    component_separators = '|',
    section_separators = '',
  },
}
require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = true,
}
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}
require "lsp_signature".setup({
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  }
})
-- vim: ts=2 sts=2 sw=2 et
