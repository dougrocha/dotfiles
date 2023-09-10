return {
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    config = function() vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" }) end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufRead", "BufNewFile" },
  },
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    event = "LspAttach",
  },
  { "folke/neodev.nvim", opts = {} },
}
