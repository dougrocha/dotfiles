return {
  -- Git related plugins
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",

  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    config = function()
      vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
    end,
  },

  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  "andweeb/presence.nvim",

  -- LSP, Formatter, Debugger dependencies
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- Github Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        auto_trigger = true,
      },
    },
  },

  -- Undotree
  "mbbill/undotree",

  -- Formatter and linter
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Debugging
  "mfussenegger/nvim-dap",

  -- Rust Tools
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    opts = function()
      local rt = require("rust-tools")
      return {
        server = {
          on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
          end,
        },
      }
    end,
  },

  -- Colorizer
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufRead",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    event = { "BufRead", "BufNewFile" },
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function() vim.cmd.colorscheme("tokyonight-storm") end,
  },

  -- Comments plugin
  {
    "folke/todo-comments.nvim",
    event = { "BufRead", "BufNewFile" },
    config = true,
  },

  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufRead", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "windwp/nvim-ts-autotag",
        opts = {
          filetypes = {
            "astro",
            "html",
            "typescriptreact",
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufRead", "BufNewFile" },
  },
}