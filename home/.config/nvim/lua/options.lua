vim.g.maplocalleader = ' '
vim.g.mapleader = ' '

-- Popup menus
vim.o.pumheight = 15
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'fuzzy' }
vim.o.winborder = 'rounded'

vim.o.mouse = 'a'

vim.o.backup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath 'data' .. '/undo'

vim.opt.wildignore:append { '.DS_Store' }

-- Update time
vim.o.timeoutlen = 500
vim.o.updatetime = 300
vim.o.ttimeoutlen = 10
vim.o.autoread = true

-- Use system clipboard
vim.o.clipboard = 'unnamedplus'

-- Search
vim.o.hlsearch = true
vim.o.inccommand = 'split'
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.infercase = true

-- Scroll size
vim.o.scrolloff = 8
vim.o.sidescrolloff = 4

-- Visual
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.signcolumn = 'yes'

-- Fold
vim.o.foldlevel = 99

-- Line Numbers
vim.wo.number = true

-- Do not Wrap long lines using words
vim.o.wrap = false
vim.o.linebreak = true

vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

-- Enable auto indentation
vim.o.autoindent = true
vim.o.expandtab = true

-- Window
vim.o.splitright = true
vim.o.splitbelow = true

-- Spell checking
vim.o.spelllang = 'en'

-- Status line
vim.o.laststatus = 3
vim.o.cmdheight = 1

-- Disable markdown style auto-formatting
vim.g.markdown_recommended_style = 0

vim.opt.shortmess:append {
    w = true,
    s = true,
}

-- Make words with dash be one word
vim.opt.iskeyword:append '-'

-- Disable certain healthchecks
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
