-- Add formatting plugins
vim.pack.add({
    "https://github.com/stevearc/conform.nvim",
})

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports", "gofmt" },
        zsh = { "beautysh" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        javascript = { "biome" },
        javascriptreact = { "biome" },
        json = { "biome" },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
})

-- Keymaps for formatting
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<Leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, opts)
vim.keymap.set("v", "<Leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, opts)
