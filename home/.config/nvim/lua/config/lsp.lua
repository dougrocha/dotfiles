local methods = vim.lsp.protocol.Methods

local function on_attach(client, bufnr)
  ---@param lhs string
  ---@param rhs string|function
  ---@param desc string
  ---@param mode? string|string[]
  local function keymap(lhs, rhs, desc, mode, opts)
    mode = mode or 'n'
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { buffer = bufnr, desc = desc }, opts or {}))
  end

  keymap('gr', '<cmd>FzfLua lsp_references<CR>', 'References', { 'n', 'x' }, { nowait = true })
  keymap('gI', '<cmd>FzfLua lsp_implementations<CR>', 'Goto implementation')
  keymap('gt', '<cmd>FzfLua lsp_typedefs ignore_current_line=true<CR>', 'Goto Type Definition')

  keymap('K', vim.lsp.buf.hover, 'Hover Information')
  keymap('<leader>rn', vim.lsp.buf.rename, 'Rename')

  keymap('<leader>ca', '<cmd>FzfLua lsp_code_actions<CR>', 'Code Actions', { 'n', 'v' })

  keymap('<leader>D', '<cmd>FzfLua diagnostics_document<CR>', 'Document Diagnostic')
  keymap('<leader>d', vim.diagnostic.open_float, 'Show Line Diagnostics')

  keymap('[d', function() vim.diagnostic.jump({ count = -1 }) end, 'Previous diagnostic')
  keymap(']d', function() vim.diagnostic.jump({ count = 1 }) end, 'Next diagnostic')

  local format_cmd = '<Cmd>lua require("conform").format({ lsp_fallback = true })<CR>'
  keymap('<leader>lf', format_cmd, 'Format')
  vim.keymap.set('v', '<leader>lf', format_cmd, { desc = 'Format selection' })

  if client:supports_method(methods.textDocument_definition) then
    keymap('gd', function() require('fzf-lua').lsp_definitions({ jump1 = true }) end, 'Go to definition')
    keymap('gD', function() require('fzf-lua').lsp_definitions({ jump1 = false }) end, 'Peek definition')
  end
end

-- Update mappings when registering dynamic capabilities.
local register_capability = vim.lsp.handlers[methods.client_registerCapability]
vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then return end

  on_attach(client, vim.api.nvim_get_current_buf())

  return register_capability(err, res, ctx)
end

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Setup LSP keymaps',
  callback = function(event)
    vim.bo[event.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end

    local bufnr = event.buf

    on_attach(client, bufnr)
  end,
})

local diagnostic_icons = { ERROR = ' ', WARN = ' ', HINT = '󰠠 ', INFO = ' ' }
for severity, icon in pairs(diagnostic_icons) do
  local hl = 'DiagnosticSign' .. severity:sub(1, 1) .. severity:sub(2):lower()
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

vim.diagnostic.config({
  virtual_text = {
    prefix = '',
    spacing = 2,
    format = function(diagnostic)
      -- Use shorter, nicer names for some sources:
      local special_sources = {
        ['Lua Diagnostics.'] = 'lua',
        ['Lua Syntax Check.'] = 'lua',
      }

      local message = diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]]
      if diagnostic.source then
        message = string.format('%s %s', message, special_sources[diagnostic.source] or diagnostic.source)
      end
      if diagnostic.code then message = string.format('%s[%s]', message, diagnostic.code) end

      return message .. ' '
    end,
  },
  float = {
    source = 'if_many',
    prefix = function(diag)
      local level = vim.diagnostic.severity[diag.severity]
      local prefix = string.format(' %s ', diagnostic_icons[level])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
  signs = false,
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  callback = function()
    vim.lsp.config('*', {
      root_markers = { '.git' },
    })

    vim.lsp.enable({
      'clangd',
      'gopls',
      'eslint',
      'lua_ls',
      'marksman',
      'tailwindcss',
      'vtsls',
    })
  end,
})
