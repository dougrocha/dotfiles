return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  cmd = { "TodoTrouble", "TododTelescope", "TodoLocList", "TodoQuickFix" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = { signs = false },
}
