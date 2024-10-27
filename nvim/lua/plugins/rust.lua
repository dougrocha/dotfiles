return {
  "mrcjkb/rustaceanvim",
  ft = { "rust" },
  version = "^5",
  lazy = false,
  config = function()
    vim.g.rustfmt_autosave = 1
    vim.g.rustfmt_emit_files = 1
    vim.g.rustfmt_fail_silently = 0
    vim.g.rust_clip_command = "wl-copy"

    vim.g.rustaceanvim = {
      -- Plugin configuration
      tools = {},
      -- LSP configuration
      server = {
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
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
          },
        },
      },
      -- DAP configuration
      dap = {},
    }
  end,
}
