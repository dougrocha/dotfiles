return {
  -- Git related plugins
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",

  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
  },

  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

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

  -- Formatter and linter
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    requires = { "nvim-lua/plenary.nvim" },
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

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "L3MON4D3/LuaSnip", opts = {} },
      "saadparwaiz1/cmp_luasnip",
    },
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
        file = {
          "astro",
          "html",
          "typescriptreact",
        },
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
}
