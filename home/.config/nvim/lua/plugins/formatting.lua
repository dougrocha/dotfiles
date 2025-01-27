return {
  'stevearc/conform.nvim',
  event = { 'LspAttach', 'BufWritePre', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  opts = {
    formatters_by_ft = {
      c = { 'clang-format' },
      cpp = { 'clang-format' },

      go = { 'gofumpt', 'goimports-reviser', 'golines' },

      lua = { 'stylua' },

      astro = { 'prettierd' },
      svelte = { 'prettierd' },
      javascript = { 'prettierd' },
      typescript = { 'prettierd' },
      typescriptreact = { 'prettierd' },
      javascriptreact = { 'prettierd' },
      json = { 'prettierd' },
      markdown = { 'prettierd' },
      toml = { 'taplo' },
    },
    default_format_opts = {
      lsp_format = 'fallback',
    },
  },
}
