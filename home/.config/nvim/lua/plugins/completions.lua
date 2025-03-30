return {
  {
    'echasnovski/mini.snippets',
    event = 'InsertEnter',
    dependencies = 'rafamadriz/friendly-snippets',
    opts = function()
      local gen_loader = require('mini.snippets').gen_loader
      return {
        snippets = {
          gen_loader.from_lang(),
        },
      }
    end,
  },
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '*',
    ---@module 'blink-cmp'
    ---@type blink.cmp.Config
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
            treesitter = { 'lsp' },
          },
        },
        list = {
          selection = { preselect = false, auto_insert = false },
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
        preset = 'mini_snippets',
      },
      sources = {
        default = {
          'lazydev',
          'lsp',
          'path',
          'snippets',
          'buffer',
        },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
    },
  },
}
