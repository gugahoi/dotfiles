-- Add LSP and related plugins
vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/rafamadriz/friendly-snippets",
    {
        src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range("*"),
    },
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/folke/lazydev.nvim",
})

-- Setup Mason
require("mason").setup()

-- Setup Mason LSPConfig
require("mason-lspconfig").setup({
    ensure_installed = {
        "gopls",
        "bashls",
        "lua_ls",
        "ts_ls",
        "tsgo",
    },
    automatic_installation = true,
})

require("lazydev").setup({
    library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
})

-- Setup blink.cmp
require("blink.cmp").setup({
    keymap = {
        preset = "default",
    },
    appearance = {
        use_nvim_cmp_as_default = false,
    },
    sources = {
        default = { "lazydev", "lsp", "path", "snippets" },
        providers = {
            lazydev = {
                name = "LazyDev",
                module = "lazydev.integrations.blink",
                score_offset = 100,
            },
        },
    },
})

-- Setup LSP capabilities with blink
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Global LSP keymaps
local function setup_keymaps(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, opts)
    -- vim.keymap.set("n", "<Leader>f", function()
    -- 	vim.lsp.buf.format({ async = true })
    -- end, opts)
    vim.keymap.set("n", "<Leader>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump({ count = -1, float = true })
    end, opts)
    vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump({ count = 1, float = true })
    end, opts)
end

-- Attach keymaps on LSP attach
---@diagnostic disable-next-line: unused-local
local on_attach = function(client, bufnr)
    setup_keymaps(bufnr)
end

-- Setup Go LSP (gopls)
vim.lsp.config("gopls", {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            gofumpt = true,
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
})

vim.lsp.config("bashls", {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "zsh", "bash", "sh" },
})

-- Setup TypeScript LSP (ts_go)
vim.lsp.config("tsgo", {
    on_attach = on_attach,
    capabilities = capabilities,
})

-- Setup TypeScript LSP (ts_ls)
vim.lsp.config("ts_ls", {
    on_attach = on_attach,
    capabilities = capabilities,
    init_options = {
        preferences = {
            quotePreference = "single",
            importModuleSpecifierPreference = "relative",
        },
    },
})

-- Setup Lua LSP (lua_ls) with Neovim builtins
vim.lsp.config("lua_ls", {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ";"),
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    "${3rd}/luv/library",
                },
                checkThirdParty = "Disable",
            },
            telemetry = {
                enable = false,
            },
        },
    },
})
