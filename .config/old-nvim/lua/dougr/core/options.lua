local opt = vim.opt

-- line numbers
opt.relativenumber = true
opt.number = true

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Start scrolling when you're 15 away from bottom (and side)
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 35

-- tabs & indentation
opt.tabstop = 2       -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2    -- 2 spaces for indent width
opt.expandtab = true  -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- line wrapping
opt.wrap = false -- disable line wrapping

-- Show live highlighting of search matches while using :substitution
vim.o.inccommand = "nosplit"

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true  -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- Undo
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = vim.fn.expand("~/.vim/undodir")
vim.o.undofile = true
