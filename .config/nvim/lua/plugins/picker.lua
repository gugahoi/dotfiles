vim.pack.add({
    "https://github.com/folke/snacks.nvim",
    "https://github.com/dmtrKovalenko/fff.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/cbochs/grapple.nvim",
})

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(event)
        if event.data.updated then
            require("fff.download").download_or_build_binary()
        end
    end,
})

-- the plugin will automatically lazy load
vim.g.fff = {
    lazy_sync = true, -- start syncing only when the picker is open
    debug = {
        enabled = true,
        show_scores = true,
    },
}

local Snacks = require("snacks")

Snacks.setup({
    explorer = { replace_netrw = true, enabled = true },
    notifier = { enabled = true },
    picker = {
        sources = {
            explorer = { hidden = true },
            files = { hidden = true },
            grep = {},
        },
    },
})

local keymaps = {
    -- stylua: ignore start
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    -- { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notifications" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },

    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    -- { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    { "<leader>sm", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>s\"", function() Snacks.picker.registers() end, desc = "Registers" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Neovim Help" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "Document Symbols" },

    -- FFF keymaps
    {"<leader>ff", function() require("fff").find_files() end,  desc = "Find files" },
    {"<leader>sg", function() require('fff').live_grep() end, desc = 'Live grep'},
    {"<leader>sz", function() require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } }) end, desc = 'Live fuzy grep',},
    {"<leader>sc", function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end, desc = 'Search current word', },

    --- Grapple keymaps
    { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
    { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
    { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
    { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
    -- stylua: ignore end
}

for _, map in ipairs(keymaps) do
    local opts = { desc = map.desc }
    if map.silent ~= nil then
        opts.silent = map.silent
    end
    if map.noremap ~= nil then
        opts.noremap = map.noremap
    else
        opts.noremap = true
    end
    if map.expr ~= nil then
        opts.expr = map.expr
    end

    local mode = map.mode or "n"
    vim.keymap.set(mode, map[1], map[2], opts)
end

-- Grapple options
-- opts = {
--     scope = "git", -- also try out "git_branch"
-- },
-- event = { "BufReadPost", "BufNewFile" },
-- cmd = "Grapple",
-- keys = {
--     { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
--     { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
--     { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
--     { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
-- }
