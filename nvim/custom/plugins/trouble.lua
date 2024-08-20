return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {},
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Toggle Trouble' },
    -- { '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Toggle Workspace Diagsnostics' },
    -- { '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Toggle Document Diagsnostics' },
    -- { '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', desc = 'Toggle Quickfix List' },
    -- { '<leader>xl', '<cmd>TroubleToggle loclist<cr>', desc = 'Toggle Location List' },
    -- { 'gR', '<cmd>TroubleToggle lsp_references<cr', desc = 'Toggle LSP References' },
  },
}
