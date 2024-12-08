vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(event)
    vim.bo[event.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

    local nmap = function(keys, rhs, desc, opts)
      opts = opts or {}
      opts.desc = desc
      vim.keymap.set('n', keys, rhs, opts)
    end

    nmap('K', vim.lsp.buf.hover, 'Information')
    nmap('gr', vim.lsp.buf.references, 'References')
    nmap('gD', vim.lsp.buf.declaration, 'Declaration')
    nmap('gi', vim.lsp.buf.implementation, 'Implementation')
    nmap('gd', vim.lsp.buf.definition, 'Definition')
    nmap('gt', vim.lsp.buf.type_definition, 'Type Definition')
    nmap('<leader>r', vim.lsp.buf.rename, 'Rename')
    -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Arguments popup')

    local format_cmd = '<Cmd>lua require("conform").format({ lsp_fallback = true })<CR>'
    nmap('<leader>lf', format_cmd, 'Format')
    vim.keymap.set('x', '<leader>lf', format_cmd, { desc = 'Format selection' })

    nmap('<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', 'Show Buffer Diagnostics')
    nmap('<leader>d', vim.diagnostic.open_float, 'Show Line Diagnostics')

    nmap('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic')
    nmap(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')

    vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, { desc = 'Code Actions' })
  end,
})

local servers = {
  'astro',
  'clangd',
  'jsonls',
  'marksman',
  'gopls',
  'lua_ls',
  'svelte',
  'vtsls',
  'tailwindcss',
}

local icons = { ERROR = ' ', WARN = ' ', HINT = '󰠠 ', INFO = ' ' }

vim.diagnostic.config({
  float = {
    source = true,
    severity_sort = true,
    prefix = function(diagnostic)
      local level = vim.diagnostic.severity[diagnostic.severity]
      local prefix = string.format(' %s ', icons[level])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
  virtual_text = {
    prefix = '',
    spacing = 2,
    format = function(diagnostic)
      local icon = icons[vim.diagnostic.severity[diagnostic.severity]]
      return string.format('%s %s ', icon, diagnostic.message)
    end,
  },
  signs = false,
  update_in_insert = false,
})

return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPost' },
  dependencies = {
    'folke/neoconf.nvim',
    { 'folke/lazydev.nvim', opts = {}, ft = 'lua' },
    { 'j-hui/fidget.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp',
    { 'williamboman/mason.nvim', build = ':MasonUpdate' },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    require('mason').setup()
    require('mason-tool-installer').setup({
      ensure_installed = {
        'prettierd',
        'stylua',
        'markdownlint',
      },
      auto_update = true,
    })

    local lsp_config = require('lspconfig')

    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    for _, server in pairs(servers) do
      local opts = {
        capabilities = capabilities,
      }

      local require_ok, settings = pcall(require, 'plugins.settings.' .. server)
      if require_ok then opts = vim.tbl_deep_extend('force', settings, opts) end

      lsp_config[server].setup(opts)
    end
  end,
}
