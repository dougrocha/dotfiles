vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(event)
    vim.bo[event.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    local nmap = function(keys, rhs, desc, opts)
      opts = opts or {}
      opts.desc = desc
      vim.keymap.set('n', keys, rhs, opts)
    end

    nmap('gd', '<cmd>FzfLua lsp_definitions<CR>', 'Goto Definition')
    nmap('gr', '<cmd>FzfLua lsp_references<CR>', 'References', { nowait = true })
    nmap('gD', vim.lsp.buf.declaration, 'Declaration')
    nmap('gI', '<cmd>FzfLua lsp_implementations<CR>', 'Goto implementation')
    nmap('gt', '<cmd>FzfLua lsp_typedefs ignore_current_line=true<CR>', 'Goto Type Definition')

    nmap('K', vim.lsp.buf.hover, 'Hover Information')
    nmap('<leader>rn', vim.lsp.buf.rename, 'Rename')

    local format_cmd = '<Cmd>lua require("conform").format({ lsp_fallback = true })<CR>'
    nmap('<leader>lf', format_cmd, 'Format')
    vim.keymap.set('v', '<leader>lf', format_cmd, { desc = 'Format selection' })

    nmap('<leader>D', '<cmd>FzfLua diagnostics_document<CR>', 'Document Diagnostic')
    nmap('<leader>d', vim.diagnostic.open_float, 'Show Line Diagnostics')

    nmap('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic')
    nmap(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')

    vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>FzfLua lsp_code_actions<CR>', { desc = 'Code Actions' })
  end,
})

return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = false,
    event = 'VeryLazy',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'lua',
        'markdown',
        'markdown_inline',
        'regex',
        'rust',
        'toml',
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    },
    config = function(_, opts) require('nvim-treesitter.configs').setup(opts) end,
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost' },
    dependencies = {
      {
        'folke/lazydev.nvim',
        opts = {
          library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        },
        ft = 'lua',
      },
      {
        'williamboman/mason.nvim',
        build = ':MasonUpdate',
        opts = {},
      },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            window = { winblend = 0 },
          },
        },
      },
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
        -- marksman = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        vtsls = {
          filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          },
          settings = {
            vtsls = {
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
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
      require('mason-tool-installer').setup({
        ensure_installed = {
          'prettierd',
          'stylua',
        },
        auto_update = true,
      })

      local lsp_config = require('lspconfig')

      for server, config in pairs(opts.servers) do
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        lsp_config[server].setup(config)
      end
    end,
  },
}
