return {
  'mfussenegger/nvim-lint',
  config = function()
    require('lint').linters_by_ft = {
      yaml = { 'actionlint' },
    }
    vim.keymap.set('n', '<leader>lb', require('lint').try_lint, { desc = '[L]int [b]uffer' })
  end,
}
