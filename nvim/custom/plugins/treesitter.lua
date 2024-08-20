return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    { 'windwp/nvim-ts-autotag', config = true },
    { 'nvim-treesitter/nvim-treesitter-context' },
  },
  build = ':TSUpdate',
  config = function()
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup {
      ensure_installed = { 'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc', 'typescript', 'go' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      auto_tag = { enabled = true },
    }

    require('treesitter-context').setup {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    }
  end,
}
