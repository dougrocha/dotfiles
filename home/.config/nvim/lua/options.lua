vim.g.maplocalleader = ' '
vim.g.mapleader = ' '

vim.o.pumheight = 15
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'fuzzy' }
vim.o.winborder = 'rounded'

vim.o.exrc = true

vim.o.mouse = 'a'

vim.o.backup = false
vim.o.swapfile = false
vim.o.undofile = true

vim.opt.wildignore:append { '.DS_Store' }

vim.o.timeoutlen = 500
vim.o.updatetime = 300
vim.o.ttimeoutlen = 10

vim.o.clipboard = 'unnamedplus'

vim.o.inccommand = 'split'
vim.o.ignorecase = true
vim.o.infercase = true

vim.o.scrolloff = 8
vim.o.sidescrolloff = 4

vim.o.showmode = false
vim.o.signcolumn = 'yes'

vim.o.foldlevel = 99

vim.o.number = true

vim.o.wrap = false
vim.o.linebreak = true

vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

vim.o.expandtab = true

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.spelllang = 'en'

vim.o.laststatus = 3

vim.g.markdown_recommended_style = 0

vim.opt.shortmess:append {
    w = true,
    s = true,
}

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
