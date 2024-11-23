return {
  "stevearc/conform.nvim",
  event = { "LspAttach", "BufWritePre", "BufNewFile" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      c = { "clang-format" },
      cpp = { "clang-format" },

      go = { "gofumpt", "goimports-reviser", "golines" },

      lua = { "stylua" },

      astro = { "prettierd", "prettier", stop_after_first = true },
      svelte = { "prettierd", "prettier", stop_after_first = true },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "markdownlint" },
      toml = { "taplo" },
    },
  },
}
