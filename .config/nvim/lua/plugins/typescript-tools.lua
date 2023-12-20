return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  config = function()
    local ts_tools = require("typescript-tools")
    local api = require("typescript-tools.api")

    ts_tools.setup({
      handlers = {
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics({ 6133 }),
      },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>m", "<cmd>TSToolsOrganizeImports<CR>")
    keymap.set("n", "<leader>ta", "<cmd>TSToolsAddMissingImports<CR>")
  end,
}
