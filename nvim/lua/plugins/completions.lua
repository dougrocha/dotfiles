return {
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = 'v0.*',
    dependencies = {
      { 'L3MON4D3/LuaSnip', version = 'v2.*' },
      'rafamadriz/friendly-snippets',
    },
    opts = {
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        menu = {
          draw = {
            columns = { { 'label', 'label_description', gap = 1 }, { 'kind' } },
          },
        },
        list = {
          selection = 'manual',
        },
      },
      keymap = {
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
      },
      snippets = {
        expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
        active = function(filter)
          if filter and filter.direction then return require('luasnip').jumpable(filter.direction) end
          return require('luasnip').in_snippet()
        end,
        jump = function(direction) require('luasnip').jump(direction) end,
      },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'buffer', 'snippets' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      },
    },
  },
  -- {
  --   'hrsh7th/nvim-cmp',
  --   event = 'InsertEnter',
  --   enabled = false,
  --   dependencies = {
  --     'hrsh7th/cmp-nvim-lsp',
  --     'hrsh7th/cmp-path',
  --     'hrsh7th/cmp-buffer',
  --     { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
  --     'saadparwaiz1/cmp_luasnip',
  --     'rafamadriz/friendly-snippets',
  --   },
  --   config = function()
  --     local cmp = require('cmp')
  --     local luasnip = require('luasnip')
  --
  --     require('luasnip.loaders.from_vscode').lazy_load()
  --
  --     cmp.setup.cmdline('/', {
  --       mapping = cmp.mapping.preset.cmdline(),
  --       sources = {
  --         { name = 'buffer' },
  --       },
  --     })
  --
  --     cmp.setup({
  --       sources = cmp.config.sources({
  --         { name = 'nvim_lsp' },
  --         { name = 'path' },
  --         { name = 'buffer', keyword_length = 3 },
  --         { name = 'luasnip', keyword_length = 2 },
  --       }, {
  --         {
  --           name = 'lazydev',
  --           group_index = 0,
  --         },
  --       }),
  --       snippet = {
  --         expand = function(args) luasnip.lsp_expand(args.body) end,
  --       },
  --       mapping = cmp.mapping.preset.insert({
  --         ['<C-n>'] = cmp.mapping.select_next_item(), -- next suggestion
  --         ['<C-p>'] = cmp.mapping.select_prev_item(), -- previous suggestion
  --
  --         -- scroll docs in cmp menu
  --         ['<C-u>'] = cmp.mapping.scroll_docs(-4),
  --         ['<C-d>'] = cmp.mapping.scroll_docs(4),
  --
  --         -- <c-l> will move right in current snippet expansion.
  --         ['<C-l>'] = cmp.mapping(function()
  --           if luasnip.expand_or_locally_jumpable() then return luasnip.expand_or_jump() end
  --         end, { 'i', 's' }),
  --         -- <c-h> will move left in current snippet expansion.
  --         ['<C-h>'] = cmp.mapping(function()
  --           if luasnip.locally_jumpable(-1) then return luasnip.jump(-1) end
  --         end, { 'i', 's' }),
  --
  --         ['<C-e>'] = cmp.mapping.abort(), -- close competion window
  --
  --         ['<CR>'] = cmp.mapping.confirm({
  --           select = false,
  --         }),
  --       }),
  --     })
  --   end,
  -- },
}
