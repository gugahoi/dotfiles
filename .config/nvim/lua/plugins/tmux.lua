vim.g.tmux_navigator_no_mappings = 1
vim.pack.add({
    "https://github.com/christoomey/vim-tmux-navigator",
})

-- In Rex (without tmux), hand off to Rex panes at the edge of nvim's splits.
-- The other half, passing ctrl+hjkl through to nvim, is in ~/.config/rex/init.lua.
local in_rex = vim.env.REX_SESSION and not vim.env.TMUX

for key, dir in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
    vim.keymap.set("n", "<c-" .. key .. ">", function()
        if not in_rex then
            return vim.cmd("TmuxNavigate" .. dir)
        end
        local win = vim.api.nvim_get_current_win()
        vim.cmd.wincmd(key)
        if win == vim.api.nvim_get_current_win() then
            vim.system({ "rex", "focus", dir:lower(), "--wrap", "-s", vim.env.REX_SESSION })
        end
    end, { silent = true, noremap = true })
end
vim.keymap.set(
    "n",
    "<c-\\>",
    "<cmd><C-U>TmuxNavigatePrevious<cr>",
    { silent = true, noremap = true }
)
