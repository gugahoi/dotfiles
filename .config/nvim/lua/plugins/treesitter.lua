vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        branch = "main",
        data = {
            on_update = function()
                vim.cmd("TSUpdate")
            end,
        },
    },
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
    },
    {
        src = "https://github.com/windwp/nvim-ts-autotag",
        branch = "main",
    },
})

require("nvim-treesitter").setup()
local parsers = {
    "bash",
    "comment",
    "css",
    "dockerfile",
    "gitcommit",
    "go",
    "javascript",
    "jsdoc",
    "json",
    "lua",
    "markdown",
    "sql",
    "terraform",
    "tsx",
    "typescript",
    "vim",
    "yaml",
}

vim.api.nvim_create_user_command("TSInstallConfigured", function()
    require("nvim-treesitter").install(parsers, { force = false })
end, { desc = "Install configured Treesitter parsers" })

vim.api.nvim_create_autocmd("PackChanged", {
    desc = "Handle nvim-treesitter updates",
    group = vim.api.nvim_create_augroup(
        "nvim-treesitter-pack-changed-update-handler",
        { clear = true }
    ),
    callback = function(event)
        if event.data.kind == "update" then
            local ok = pcall(vim.cmd, "TSUpdate")
            if ok then
                vim.notify(
                    "TSUpdate completed successfully!",
                    vim.log.levels.INFO
                )
            else
                vim.notify(
                    "TSUpdate command not available yet, skipping",
                    vim.log.levels.WARN
                )
            end
        end
    end,
})

vim.opt.foldlevel = 99

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "*" },
    callback = function()
        local filetype = vim.bo.filetype
        if filetype and filetype ~= "" then
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo.foldmethod = "expr"
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

            local success = pcall(function()
                vim.treesitter.start()
            end)
            if not success then
                return
            end
        end
    end,
})

require("nvim-treesitter-textobjects").setup({
    select = { lookahead = true },
    move = { set_jumps = true },
})
vim.keymap.set({ "x", "o" }, "am", function()
    require("nvim-treesitter-textobjects.select").select_textobject(
        "@function.outer",
        "textobjects"
    )
end)
vim.keymap.set({ "x", "o" }, "im", function()
    require("nvim-treesitter-textobjects.select").select_textobject(
        "@function.inner",
        "textobjects"
    )
end)
vim.keymap.set({ "x", "o" }, "ac", function()
    require("nvim-treesitter-textobjects.select").select_textobject(
        "@class.outer",
        "textobjects"
    )
end)
vim.keymap.set({ "x", "o" }, "ic", function()
    require("nvim-treesitter-textobjects.select").select_textobject(
        "@class.inner",
        "textobjects"
    )
end)
vim.keymap.set({ "n", "x", "o" }, "]m", function()
    require("nvim-treesitter-textobjects.move").goto_next_start(
        "@function.outer",
        "textobjects"
    )
end)
vim.keymap.set({ "n", "x", "o" }, "]]", function()
    require("nvim-treesitter-textobjects.move").goto_next_start(
        "@class.outer",
        "textobjects"
    )
end)
-- You can also pass a list to group multiple queries.
vim.keymap.set({ "n", "x", "o" }, "]o", function()
    require("nvim-treesitter-textobjects.move").goto_next_start(
        { "@loop.inner", "@loop.outer" },
        "textobjects"
    )
end)
-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
vim.keymap.set({ "n", "x", "o" }, "]s", function()
    require("nvim-treesitter-textobjects.move").goto_next_start(
        "@local.scope",
        "locals"
    )
end)
vim.keymap.set({ "n", "x", "o" }, "]z", function()
    require("nvim-treesitter-textobjects.move").goto_next_start(
        "@fold",
        "folds"
    )
end)

vim.keymap.set({ "n", "x", "o" }, "]M", function()
    require("nvim-treesitter-textobjects.move").goto_next_end(
        "@function.outer",
        "textobjects"
    )
end)
vim.keymap.set({ "n", "x", "o" }, "][", function()
    require("nvim-treesitter-textobjects.move").goto_next_end(
        "@class.outer",
        "textobjects"
    )
end)

vim.keymap.set({ "n", "x", "o" }, "[m", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start(
        "@function.outer",
        "textobjects"
    )
end)
vim.keymap.set({ "n", "x", "o" }, "[[", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start(
        "@class.outer",
        "textobjects"
    )
end)

vim.keymap.set({ "n", "x", "o" }, "[M", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end(
        "@function.outer",
        "textobjects"
    )
end)
vim.keymap.set({ "n", "x", "o" }, "[]", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end(
        "@class.outer",
        "textobjects"
    )
end)

require("nvim-ts-autotag").setup({
    opts = {
        -- Defaults
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = false, -- Auto close on trailing </
    },
    -- Also override individual filetype configs, these take priority.
    -- Empty by default, useful if one of the "opts" global settings
    -- doesn't work well in a specific filetype
    per_filetype = {
        ["html"] = {
            enable_close = false,
        },
    },
})
