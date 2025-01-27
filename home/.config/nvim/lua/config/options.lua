vim.opt.mouse = 'a'          -- Enable mouse support
vim.opt.backup = false       -- Creates a backup file
vim.opt.switchbuf = 'usetab' -- Use already opened buffer
vim.opt.undofile = true      -- Enable persistent undo
vim.opt.swapfile = false     -- Disable swap files

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

vim.opt.timeoutlen = 300           -- Time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.updatetime = 250           -- Faster completion (4000ms Default)

vim.opt.clipboard = 'unnamedplus'  -- Sync with system clipboard

vim.opt.hlsearch = true            -- Highlight previous search results
vim.opt.inccommand = 'split'       -- Show live preview of substitution, as you type

vim.opt.scrolloff = 4              -- Make sure there are always 2 lines below cursor
vim.opt.sidescrolloff = 8          -- Make sure there are always 8 lines to the left and right of cursor

vim.opt.showmode = false           -- Don't show since I use a custom status line
vim.opt.termguicolors = true       -- True color support
vim.opt.signcolumn = 'yes'         -- Always show the sign column
vim.opt.number = true              -- Use Line Numbers
vim.opt.relativenumber = true      -- Use Relative Line Numbers
vim.opt.pumheight = 10             -- Max completion items
vim.opt.splitbelow = true          -- Force all horizontal splits to go below current window
vim.opt.splitright = true          -- Force all vertical splits to go to the right of current window
vim.opt.wrap = false               -- Turn off line wrapping
vim.opt.ruler = false              -- Do not show cursor position

vim.opt.autoindent = true          -- Copy indent from current line when starting a new line
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.ignorecase = true          -- Ignore case while searching
vim.opt.incsearch = true           -- Ignore case in search pattern
vim.opt.infercase = true           -- Infer letter cases while searching
vim.opt.formatoptions = 'jcroqlnt' -- Improve comment editing
vim.opt.tabstop = 2                -- Number of spaces tabs count for
vim.opt.shiftwidth = 2             -- Number of spaces for indent width
vim.opt.smartcase = true           -- Don't ignore case with capitals
vim.opt.smartindent = true         -- Indent Automatically

vim.opt.colorcolumn = '120'

-- Spelling
vim.opt.spelllang = 'en'
vim.opt.spelloptions = 'camel'

vim.g.markdown_recommended_style = 0

if vim.fn.has('nvim-0.11') == 1 then
  vim.opt.completeopt:append('fuzzy') -- Use fuzzy matching for built-in completion
end
