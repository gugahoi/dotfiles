vim.pack.add({
    "https://github.com/christoomey/vim-tmux-navigator",
})

vim.keymap.set(
    "n",
    "<c-h>",
    "<cmd><C-U>TmuxNavigateLeft<cr>",
    { silent = true, noremap = true }
)
vim.keymap.set(
    "n",
    "<c-j>",
    "<cmd><C-U>TmuxNavigateDown<cr>",
    { silent = true, noremap = true }
)
vim.keymap.set(
    "n",
    "<c-k>",
    "<cmd><C-U>TmuxNavigateUp<cr>",
    { silent = true, noremap = true }
)
vim.keymap.set(
    "n",
    "<c-l>",
    "<cmd><C-U>TmuxNavigateRight<cr>",
    { silent = true, noremap = true }
)
vim.keymap.set(
    "n",
    "<c-\\>",
    "<cmd><C-U>TmuxNavigatePrevious<cr>",
    { silent = true, noremap = true }
)
