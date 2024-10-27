local opt = vim.opt

opt.mouse = "a" -- Enable mouse support

opt.listchars = "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•"

opt.clipboard = "unnamedplus" -- Sync with system clipboard
-- opt.completeopt = { "menu", "menuone", "noselect" } -- For cmp

-- opt.timeoutlen = 300 -- Time to wait for a mapped sequence to complete (in milliseconds)
-- opt.updatetime = 250 -- Faster completion (4000ms Default)

opt.hlsearch = true -- Highlight previous search results
opt.incsearch = true -- ignore case in search pattern
opt.inccommand = "split" -- Show live preview of substitution, as you type

opt.signcolumn = "yes" -- Always show the sign column
opt.number = true -- Use Line Numbers
opt.relativenumber = true -- Use Relative Line Numbers

opt.scrolloff = 2 -- Make sure there are always 2 lines below cursor
opt.sidescrolloff = 8 -- Make sure there are always 8 lines to the left and right of cursor
opt.tabstop = 4 -- Number of spaces tabs count for
opt.shiftwidth = 4 -- Number of spaces for indent width

opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Indent Automatically

opt.showmode = false -- Don't show since I use a custom status line
opt.spelllang = { "en" } -- Spelling language
opt.termguicolors = true -- True color support
opt.shiftround = true -- Round indent
opt.expandtab = true -- Use spaces instead of tabs
opt.autoindent = true -- Copy indent from current line when starting a new line

opt.splitbelow = true -- Force all horizontal splits to go below current window
opt.splitright = true -- Force all vertical splits to go to the right of current window

opt.colorcolumn = "80"

opt.backup = false -- creates a backup file
opt.swapfile = false -- No swap file
opt.timeout = true -- Enable timeout
opt.undofile = true -- Enable persistent undo
opt.undolevels = 10000 -- Number of undo levels

opt.wrap = false -- Turn off line wrapping
