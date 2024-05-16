return {
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    cmd = { "TodoTrouble", "TododTelescope", "TodoLocList", "TodoQuickFix" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
  {
    "echasnovski/mini.comment",
    event = "BufReadPost",
    version = "*",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("mini.comment").setup({
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
          end,
        },
      })
    end,
  },
}
