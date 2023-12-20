return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  build = ":MasonUpdate",
  config = function()
    local mason = require("mason")

    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "tsserver",
        "html",
        "tailwindcss",
        "marksman",
        "lua_ls",
        "svelte",
        "jsonls",
        "rust_analyzer",
      },
      automatic_installation = true,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettierd",
        "stylua",
        "eslint_d",
        "markdownlint",
        "luacheck",
      },
    })
  end,
}
