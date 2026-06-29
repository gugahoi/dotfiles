local map = vim.keymap.set

map(
    "n",
    "<leader>bd",
    ":bdelete<cr>",
    { silent = true, desc = "Close current buffer" }
)
map(
    "n",
    "<leader>bD",
    ":bdelete!<cr>",
    { silent = true, desc = "Close current buffer (force)" }
)
map(
    "n",
    "<leader>bo",
    ":%bd|e#|bd#<cr>",
    { desc = "Close other buffers", silent = true }
)
map("n", "<Esc>", ":nohlsearch<cr>", { silent = true })

-- Exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- stylua: ignore start
vim.keymap.set({ "n", "v" }, "gy", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set( { "n", "v" }, "gY", '"+Y', { desc = "Yank line to system clipboard" })
vim.keymap.set( "n", "gp", '"+p', { desc = "Paste from system clipboard after cursor" })
vim.keymap.set( "n", "gP", '"+P', { desc = "Paste from system clipboard before cursor" })
-- stylua: ignore end

vim.keymap.set("n", "<leader>cl", function()
    local file = vim.fn.expand("%")
    local line = vim.fn.line(".")
    local result = file .. ":" .. line
    vim.fn.setreg("+", result)
    vim.notify("Copied: " .. result) -- Optional notification
end, { desc = "Copy filename and line number" })
