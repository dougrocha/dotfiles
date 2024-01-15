return {
  "pmizio/typescript-tools.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  keys = {
    { "<leader>tm", "<cmd>TSToolsOrganizeImports<cr>" },
    { "<leader>ta", "<cmd>TSToolsAddMissingImports<cr>" },
  },
  config = function()
    local ts_tools = require("typescript-tools")
    local api = require("typescript-tools.api")

    ts_tools.setup({
      handlers = {
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics({ 6133 }),
      },
    })
  end,
}
