-- Telescope
local telescope = require('telescope')
telescope.setup {
  defaultelescope = {
    mappings = {
      n = {
        -- CTRL + d deletes a buffer in Telescope
        ['<C-d>'] = require('telescope.actions').delete_buffer
      },
    },
    pickers = {
      find_files = {
        hidden = true
      }
    }
  },
}

telescope.load_extension 'frecency'
telescope.load_extension 'fzf'
