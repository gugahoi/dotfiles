return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = 'master',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
  },
  config = function()
    require('telescope').setup {
      defaults = {
        path_display = {
          -- 'smart',
          'filename_first',
          -- shorten = {
          --   len = 1,
          --   exclude = { -1, -2 }, -- show filename and the parent folder name, truncate the rest to 1 character
          -- },
        },
        dynamic_preview_title = true,
        sorting_strategy = 'ascending',
        layout_strategy = 'vertical',
        layout_config = {
          mirror = true,
          height = 0.95,
          prompt_position = 'top',
        },
        mappings = {
          i = {
            ['<C-h>'] = require('telescope.actions.layout').toggle_preview,
          },
          n = {
            ['<C-h>'] = require('telescope.actions.layout').toggle_preview,
          },
        },
      },
      pickers = {
        find_files = {
          previewer = false,
        },
        buffers = {
          ignore_current_buffer = true,
          mappings = {
            i = {
              ['<C-s>'] = 'delete_buffer',
            },
            n = {
              ['d'] = 'delete_buffer',
            },
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable telescope extensions, if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- Local search mappings
    local root = require 'custom.util.root'
    vim.keymap.set('n', '<leader>sf', function()
      builtin.find_files { cwd = root.get() }
    end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sg', function()
      builtin.live_grep { cwd = root.get(), hidden = true }
    end, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sw', function()
      builtin.grep_string { cwd = root.get(), hidden = true }
    end, { desc = '[S]earch current [W]ord' })

    -- Top Search Mappings
    vim.keymap.set('n', '<leader>sF', builtin.find_files, { desc = '[S]earch [F]iles (Root)' })
    vim.keymap.set('n', '<leader>sG', builtin.live_grep, { desc = '[S]earch by [G]rep (Root)' })
    vim.keymap.set('n', '<leader>sW', builtin.grep_string, { desc = '[S]earch current [W]ord (Root)' })

    -- Open registers in Telescope
    vim.keymap.set('n', '"', builtin.registers)

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- Also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
