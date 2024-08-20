local root = require 'custom.util.root'

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = true,
  opts = {
    open_mapping = [[<c-\>]],
    terminal_mappings = true,
    direction = 'float',
  },
  keys = {
    { '<Leader>tf', ':ToggleTerm direction=float<cr>', desc = 'Open Floating terminal' },
    { '<Leader>tv', ':ToggleTerm direction=vertical<cr>', desc = 'Open vertical terminal' },
    { '<Leader>th', ':ToggleTerm direction=horizontal<cr>', desc = 'Open horizontal terminal' },
    {
      '<Leader>tn',
      function()
        require('toggleterm.terminal').Terminal:new():open { dir = root.get() }
      end,
      desc = 'Open new terminal',
    },
    { '<Leader>ts', ':TermSelect<cr>', desc = 'Select from open terminals' },
  },
}
