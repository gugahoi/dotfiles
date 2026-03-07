local map = vim.keymap.set

map("n", "<leader>bd", ":bdelete<cr>")
map("n", "<Esc>", ":nohlsearch<cr>")

-- Exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
