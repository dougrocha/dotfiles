vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(event)
    vim.bo[event.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    local nmap = function(keys, rhs, desc, opts)
      opts = opts or {}
      opts.desc = desc
      vim.keymap.set('n', keys, rhs, opts)
    end

    nmap('K', vim.lsp.buf.hover, 'Information')
    nmap('gr', require('telescope.builtin').lsp_references, 'References')
    nmap('gD', vim.lsp.buf.declaration, 'Declaration')
    nmap('gi', require('telescope.builtin').lsp_implementations, 'Implementation')
    nmap('gd', require('telescope.builtin').lsp_definitions, 'Definition')
    nmap('gt', require('telescope.builtin').lsp_type_definitions, 'Type Definition')
    nmap('<leader>r', vim.lsp.buf.rename, 'Rename')

    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

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
    { 'folke/lazydev.nvim', opts = {}, ft = 'lua' },
    { 'williamboman/mason.nvim', build = ':MasonUpdate' },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  opts = {
    servers = {
      clangd = {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
        },
      },
      gopls = {},
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
      svelte = {
        on_attach = function(client)
          vim.api.nvim_create_autocmd('BufWritePost', {
            pattern = { '*.js', '*.ts' },
            callback = function(ctx)
              if client.name == 'svelte' then client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.file }) end
            end,
          })
        end,
      },
    },
  },
  config = function(_, opts)
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

    for server, config in pairs(opts.servers) do
      config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
      lsp_config[server].setup(config)
    end
  end,
}
