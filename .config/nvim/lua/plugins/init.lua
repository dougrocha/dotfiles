return {
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "kdheepak/lazygit.nvim",

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
    requires = { "nvim-lua/plenary.nvim" },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
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
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "L3MON4D3/LuaSnip", opts = {} },
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Colorizer
  {
    "NvChad/nvim-colorizer.lua",
    lazy = true,
    event = "BufRead",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },

  -- Useful plugin to show you pending keybinds.
  { "folke/which-key.nvim", opts = {} },

  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    lazy = true,
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
    priority = 50,
    config = function() vim.cmd.colorscheme("tokyonight-storm") end,
  },

  -- Comments plugin
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {},
  },

  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "windwp/nvim-ts-autotag",
        opts = {
          filetypes = {
            "html",
            "typescriptreact",
            "astro",
          },
        },
      },
    },
    config = function() pcall(require("nvim-treesitter.install").update({ with_sync = true })) end,
  },
}
