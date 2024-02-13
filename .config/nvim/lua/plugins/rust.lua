return {
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      vim.g.rustaceanvim = {
        inlay_hints = {
          highlight = "NonText",
        },
        tools = {
          hover_actions = {
            auto_focus = true,
          },
        },
        server = {
          on_attach = function(client, bufnr)
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(bufnr, true)
            end
          end,
        },
      }
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
        popup = {
          border = "rounded",
        },
      })
    end,
  },
}
