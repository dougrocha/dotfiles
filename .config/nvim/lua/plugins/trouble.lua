return {
  "folke/trouble.nvim",
  cmd = { "TroubleToggle", "Trouble" },
  opts = { use_diagnostic_signs = true },
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Open (Trouble)" },
    { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
    { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
    { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Loclist (Trouble)" },
    { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix (Trouble)" },
    { "<leader>gR", "<cmd>TroubleToggle lsp_references<cr>", desc = "Trouble" },
  },
}
