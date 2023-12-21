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
    "simrat39/rust-tools.nvim",
    config = function()
      require("rust-tools").setup({
        server = {
          on_attach = function(_, bufnr)
            -- Hover Actions
            vim.keymap.set(
              "n",
              "<leader>k",
              "<cmd>RustHoverActions<CR>",
              { buffer = bufnr, noremap = true, silent = true }
            )
            -- Code Actions
            vim.keymap.set(
              "n",
              "<leader>cR",
              "<cmd>RustCodeAction<CR>",
              { buffer = bufnr, noremap = true, silent = true }
            )
          end,
        },
      })
    end,
  },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },
}
