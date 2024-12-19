-- code from full spec in https://www.lazyvim.org/plugins/linting
local function conditionally_try_lint(conditional_linters)
  local lint = require('lint')

  conditional_linters = vim.list_extend({}, conditional_linters)

  local names = lint._resolve_linter_by_ft(vim.bo.filetype)
  -- Create a copy of the names table to avoid modifying the original.
  names = vim.list_extend({}, names)
  -- Filter out linters that don't exist or don't match the condition.
  local ctx = { filename = vim.api.nvim_buf_get_name(0) }
  ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
  names = vim.tbl_filter(function(name)
    local linter = conditional_linters[name]
    return linter and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
  end, names)
  -- Run linters.
  if #names > 0 then lint.try_lint(names) end
end

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  keys = {
    {
      '<leader>ll',
      function() require('lint').try_lint() end,
      desc = 'Lint current buffer',
    },
  },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      lua = { 'selene' },
      svelte = { 'eslint_d' },
      markdown = { 'markdownlint' },
    }

    -- Conditional Linters only for auto lint, do not use for manual key bind
    local conditional_linters = {
      selene = {
        condition = function(ctx) return vim.fs.find({ 'selene.toml' }, { path = ctx.filename, upward = true })[1] end,
      },
    }

    -- Enable auto linting
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('lint', {
        clear = true,
      }),
      callback = function() conditionally_try_lint(conditional_linters) end,
    })
  end,
}
