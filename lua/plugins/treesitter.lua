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
})

require("nvim-treesitter").setup()
require("nvim-treesitter").install({
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
}, { force = false, summary = false })

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

-- Folds
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldmethod = "expr"
vim.opt.foldlevel = 99

-- Indentation [experimental]
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "*" },
    callback = function()
        local filetype = vim.bo.filetype
        if filetype and filetype ~= "" then
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
