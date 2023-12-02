vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.autoformat = true

vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

local opt = vim.opt

opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"

-- Set highlight on search
opt.hlsearch = false
opt.incsearch = true

opt.formatoptions = "jcroqlnt" -- tcjq
opt.grepformat = "rg -vimgrep"

opt.scrolloff = 10
opt.sidescrolloff = 35

opt.signcolumn = "yes"

opt.number = true -- Use Line Numbers
opt.relativenumber = true -- Use Relative Line Numbers

opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Indent Automatically

opt.showmode = false -- Don't show since I use a custom status line

opt.spelllang = { "en" } -- Spelling language

opt.termguicolors = true -- True color support

opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Number of spaces for indent width
opt.shiftround = true -- Round indent
opt.expandtab = true -- Use spaces instead of tabs

opt.splitbelow = true -- Put new windows under current window
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows to the right of current window

opt.timeout = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold

opt.wrap = false -- Turn off line wrapping

opt.wildmode = "longest:full,full" -- Command-line completion mode
