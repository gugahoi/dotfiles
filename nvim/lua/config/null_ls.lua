-- null-ls
local null_ls = require("null-ls")
local built_ins = null_ls.builtins
null_ls.setup({
  sources = {
    built_ins.formatting.prettier,
    built_ins.formatting.shfmt,
    built_ins.formatting.fixjson,

    built_ins.diagnostics.eslint,
    built_ins.diagnostics.write_good,
    -- built_ins.diagnostics.tsc,
    built_ins.diagnostics.shellcheck,

    built_ins.hover.dictionary,
  },
  on_attach = function(client, bufnr)
    if client.name == "tsserver" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.code_action("source.organizeImports")
        end
      })
    end
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        -- on 0.8, you should use vim.lsp.buf.format instead
        callback = function()
          vim.lsp.buf.formatting()
        end
      })
    end
  end,
})
