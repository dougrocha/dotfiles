-----------------------------------------------------------
-- Plugin manager configuration file
-----------------------------------------------------------

-- Plugin manager: packer.nvim
-- url: https://github.com/wbthomason/packer.nvim

-- For information about installed plugins see the README:
-- neovim-lua/README.md
-- https://github.com/brainfucksec/neovim-lua#readme

-- Automatically install packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path
  })
  vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
end

-- Autocommand that reloads neovim whenever you save the packer_init.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer_init.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  return
end

-- Install plugins
return packer.startup(function(use)
  -- Add you plugins here:

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Nightfly theme
  -- use 'bluz71/vim-nightfly-guicolors'
  -- Tokyo Night Theme
  use 'folke/tokyonight.nvim'

  -- Popup API
  use 'nvim-lua/popup.nvim'

  -- Git Plugin
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'

  -- Tabs
  use {
    'romgrk/barbar.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- Side File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
    tag = 'nightly' -- optional, updated every week. (see issue #1193)
  }

  -- Indent line
  use 'lukas-reineke/indent-blankline.nvim'

  -- Auto Commenting Plugin
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }

  -- Autocomplete
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      'hrsh7th/cmp-cmdline',
      "hrsh7th/cmp-path",
      'hrsh7th/cmp-omni',
      "onsails/lspkind-nvim", -- Enables icons on completions
      { -- Snippets
        "L3MON4D3/LuaSnip",
        requires = {
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
      },
    }
  }


  -- Which key
  use 'folke/which-key.nvim'

  -- Language Server Plugins
  use {
    "williamboman/nvim-lsp-installer",
    "neovim/nvim-lspconfig",
  }
  use({
    "glepnir/lspsaga.nvim",
    branch = "main",
  })
  -- LSP Color Theme
  use {
    'folke/lsp-colors.nvim',
    config = function()
      require('lsp-colors').setup({
        Error = "#db5b4b",
        Warning = "#e1af68",
        Information = "#1db9d7",
        Hint = "#11B981"
      })
    end
  }

  -- LSP Rust
  use {
    'simrat39/rust-tools.nvim',
    config = function()
      require('rust-tools').setup({})
    end
  }

  -- Debugging
  use 'mfussenegger/nvim-dap'

  use {
    'nvim-lualine/lualine.nvim',
    options = {
      -- theme = 'nightfly'
      theme = 'tokyonight'
    },
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- Treesitter interface
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }

  -- Autopair
  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
    end
  }

  -- HTML Autotag
  use {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup()
    end
  }

  -- Dashboard (start screen)
  use {
    'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
  }

  use({
    "iamcco/markdown-preview.nvim",
    run = "cd app && yarn install",
    ft = { "markdown" },
    setup = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  })

  -- Colorizer for Hex Codes
  use 'norcalli/nvim-colorizer.lua'

  -- Project Time Tracker
  use 'wakatime/vim-wakatime'

  -- Todo Commment Highlight https://github.com/folke/todo-comments.nvim
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end
  }

  --
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
