local root = require 'custom.util.root'

return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-jest',
  },
  config = function()
    local neotest = require 'neotest'
    neotest.setup {
      adapters = {
        require 'neotest-jest' {
          jestCommand = 'yarn test ',
          env = { CI = true },
          jestConfigFile = function()
            return root.get() .. '/jest.config.ts'
          end,
          cwd = function()
            return root.get()
          end,
        },
      },
    }

    vim.keymap.set('n', '<leader>tt', neotest.run.run, { desc = 'Tests: Run' })
    vim.keymap.set('n', '<leader>tf', function()
      neotest.run.run(vim.fn.expand '%:t')
    end, { desc = 'Tests: Run' })
    vim.keymap.set('n', '<leader>tw', function()
      neotest.run.run { jestCommand = 'yarn test --watch ' }
    end, { desc = 'Test: watch' })
    vim.keymap.set('n', '<leader>to', neotest.output_panel.toggle, { desc = 'Test: Toggle Output' })
    vim.keymap.set('n', '<leader>tb', neotest.summary.toggle, { desc = 'Test: Toggle Summary' })
    vim.keymap.set('n', '[n', neotest.jump.prev, { desc = 'Test: Go To Previous' })
    vim.keymap.set('n', ']n', neotest.jump.next, { desc = 'Test: Go To Next' })
  end,
}
