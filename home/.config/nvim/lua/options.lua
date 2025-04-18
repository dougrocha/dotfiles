vim.g.maplocalleader = ' '
vim.g.mapleader = ' '

-- Enable mouse support
vim.o.mouse = 'a'

vim.o.undofile = true
vim.opt.undodir = vim.fn.stdpath('cache') .. '/undo'
vim.o.swapfile = false

-- Completion menu
vim.o.pumheight = 15
vim.o.completeopt = 'menu,menuone,noselect'

-- Update time
vim.opt.timeoutlen = 500
vim.opt.updatetime = 150
vim.o.ttimeoutlen = 10

-- Use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Search
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.infercase = true

-- Scroll size
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4

vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.wrap = false

-- Enable auto indentation
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.et = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Spell checking
vim.opt.spelllang = 'en'
vim.opt.spelloptions = 'camel'

-- Disable markdown style auto-formatting
vim.g.markdown_recommended_style = 0

-- Add fuzzy completion option if Neovim >= 0.11
if vim.fn.has('nvim-0.11') == 1 then vim.opt.completeopt:append('fuzzy') end
