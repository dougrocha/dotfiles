return {
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
    event = 'VeryLazy',
    build = ':MasonUpdate',
    opts = {},
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    event = 'VeryLazy',
    config = function()
      require('mason-tool-installer').setup({
        ensure_installed = {
          'prettierd',
          'stylua',
        },
        auto_update = true,
      })
    end,
  },
}
