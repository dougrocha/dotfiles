return {
  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },
  { "folke/neodev.nvim", lazy = true },
  { "folke/neoconf.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "echasnovski/mini.surround",
    event = "InsertEnter",
    opts = {},
  },

  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neo-tree/neo-tree.nvim",
    },
    lazy = true,
    config = function()
      require("lsp-file-operations").setup()
    end,
  },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },
}
