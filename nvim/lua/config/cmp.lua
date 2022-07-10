-- luasnip setup
local luasnip = require 'luasnip'
local cmp = require 'cmp'

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

_G.tab_complete = function()
  if cmp and cmp.visible() then
    cmp.select_next_item()
  elseif luasnip and luasnip.expand_or_jumpable() then
    return t("<Plug>luasnip-expand-or-jump")
  elseif check_back_space() then
    return t "<Tab>"
  else
    cmp.complete()
  end
  return ""
end
_G.s_tab_complete = function()
  if cmp and cmp.visible() then
    cmp.select_prev_item()
  elseif luasnip and luasnip.jumpable(-1) then
    return t("<Plug>luasnip-jump-prev")
  else
    return t "<S-Tab>"
  end
  return ""
end

-- nvim-cmp setup
cmp.setup {
  comparators = {
    cmp.config.compare.offset,
    cmp.config.compare.exact,
    cmp.config.compare.score,
    cmp.config.compare.kind,
    cmp.config.compare.sort_text,
    cmp.config.compare.length,
    cmp.config.compare.order,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-u>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(_G.tab_complete, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(_G.s_tab_complete, { 'i', 's' }),
    ['<C-e>'] = cmp.mapping.abort(),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'copilot' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'git' },
  },
}

local format = require("cmp_git.format")
local sort = require("cmp_git.sort")
require("cmp_git").setup({
  -- defaults
  filetypes = { "gitcommit", "octo" },
  remotes = { "upstream", "origin" }, -- in order of most to least prioritized
  enableRemoteUrlRewrites = false, -- enable git url rewrites, see https://git-scm.com/docs/git-config#Documentation/git-config.txt-urlltbasegtinsteadOf
  git = {
    commits = {
      limit = 100,
      sort_by = sort.git.commits,
      format = format.git.commits,
    },
  },
  github = {
    issues = {
      fields = { "title", "number", "body", "updatedAt", "state" },
      filter = "all", -- assigned, created, mentioned, subscribed, all, repos
      limit = 100,
      state = "open", -- open, closed, all
      sort_by = sort.github.issues,
      format = format.github.issues,
    },
    mentions = {
      limit = 100,
      sort_by = sort.github.mentions,
      format = format.github.mentions,
    },
    pull_requests = {
      fields = { "title", "number", "body", "updatedAt", "state" },
      limit = 100,
      state = "open", -- open, closed, merged, all
      sort_by = sort.github.pull_requests,
      format = format.github.pull_requests,
    },
  },
  trigger_actions = {
    {
      debug_name = "git_commits",
      trigger_character = ":",
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.git:get_commits(callback, params, trigger_char)
      end,
    },
    {
      debug_name = "github_issues_and_pr",
      trigger_character = "#",
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.github:get_issues_and_prs(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = "github_mentions",
      trigger_character = "@",
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.github:get_mentions(callback, git_info, trigger_char)
      end,
    },
  },
}
)

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }, {
    { name = 'buffer' },
  }),
})
