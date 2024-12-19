return {
  'mrcjkb/rustaceanvim',
  version = '^5',
  ft = { 'rust' },
  lazy = false,
  config = function()
    vim.g.rustfmt_autosave = 1
    vim.g.rustfmt_emit_files = 1
    vim.g.rustfmt_fail_silently = 0

    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          -- rust-analyzer language server configuration
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            imports = {
              group = {
                enable = false,
              },
            },
            completion = {
              postfix = {
                enable = false,
              },
            },
            procMacro = {
              enable = true,
              ignored = {
                ['async-trait'] = { 'async_trait' },
                ['napi-derive'] = { 'napi' },
                ['async-recursion'] = { 'async_recursion' },
              },
            },
          },
        },
      },
    }
  end,
}
