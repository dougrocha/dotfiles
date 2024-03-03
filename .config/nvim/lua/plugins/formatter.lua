return {
  "stevearc/conform.nvim",
  event = { "BufWritePre", "BufNewFile" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      svelte = { { "prettierd", "prettier" } },
      javascript = { { "prettierd", "prettier" } },
      typescript = { { "prettierd", "prettier" } },
      typescriptreact = { { "prettierd", "prettier" } },
      javascriptreact = { { "prettierd", "prettier" } },
      json = { { "prettierd", "prettier" } },
      markdown = { "markdownlint" },
      c = { "clang-format" },
      cpp = { "clang-format" },
    },
    -- If this is set, Conform will run the formatter on save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    format_on_save = {
      -- I recommend these options. See :help conform.format for details.
      lsp_fallback = true,
      timeout_ms = 500,
    },
    -- If this is set, Conform will run the formatter asynchronously after save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    format_after_save = {
      lsp_fallback = true,
    },
  },
}
