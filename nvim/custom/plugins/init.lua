return {
  {
    'stevearc/oil.nvim',
    opts = { columns = { 'icon', 'size' }, skip_confirm_for_simple_edits = true, view_options = { show_hidden = true } },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>ce', ':Oil<CR>', desc = 'Open File Explorer' },
      { '-', ':Oil<CR>', desc = 'Open parent directory' },
    },
  },
  { 'stevearc/overseer.nvim', opts = {} },
  { 'RaafatTurki/corn.nvim', opts = {} },
  {
    'folke/ts-comments.nvim',
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has 'nvim-0.10.0' == 1,
  },
}
