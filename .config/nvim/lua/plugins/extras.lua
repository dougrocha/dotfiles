return {
  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  { "folke/neodev.nvim", lazy = true },
  { "folke/neoconf.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  {
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },
}
