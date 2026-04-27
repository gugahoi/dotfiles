-- Add formatting plugins
vim.pack.add({
    "https://github.com/stevearc/conform.nvim",
})

require("conform").setup({
    notify_on_error = true,
    formatters_by_ft = {
        lua = { "stylua" },
        css = { "biome-check" },
        javascript = { "biome-check" },
        javascriptreact = { "biome-check" },
        typescript = { "biome-check", "prettier" },
        typescriptreact = { "biome-check", "prettier" },
        swift = { "swiftlint" },
        json = { "jq", "biome" },
        jsonc = { "jq", "biome" },
        markdown = { "rumdl" },
        toml = { "biome" },
        go = { "gofmt", "goimports-reviser", "golines" },
    },
    format_on_save = {
        timeout_ms = 300,
        lsp_format = "fallback",
    },
    formatters = {
        ["biome-check"] = {
            require_cwd = true,
        },
        ["prettier"] = {
            require_cwd = true,
        },
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
