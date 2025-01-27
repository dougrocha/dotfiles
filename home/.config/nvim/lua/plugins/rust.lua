return {
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    config = function()
      require('crates').setup({
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
      })
    end,
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    ft = { 'rust' },
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        server = {
          capabilities = vim.lsp.protocol.make_client_capabilities(),
          default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {},
          },
        },
      }
    end,
  },
}
