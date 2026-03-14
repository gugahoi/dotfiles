local map = vim.keymap.set

map("n", "<leader>bd", ":bdelete<cr>", { silent = true })
map("n", "<Esc>", ":nohlsearch<cr>", { silent = true })

-- Exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
