vim.g.maplocalleader = ' '
vim.g.mapleader = ' '

vim.o.winborder = 'rounded'

-- Enable mouse support
vim.o.mouse = 'a'

vim.o.backup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath 'cache' .. '/undo'
vim.opt.wildignore:append { '.DS_Store' }

-- Completion menu
vim.o.pumheight = 15
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

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
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 99

-- Line Numbers
vim.wo.number = true

-- Wrap long lines using words
vim.o.linebreak = true

vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

-- Enable auto indentation
vim.o.autoindent = true
vim.o.expandtab = true
vim.o.smartindent = true

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

-- Add fuzzy completion option if Neovim >= 0.11
if vim.fn.has 'nvim-0.11' == 1 then
    vim.opt.completeopt:append 'fuzzy'
end

-- Make words with dash be one word
vim.opt.iskeyword:append '-'

-- Disable certain healthchecks
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
