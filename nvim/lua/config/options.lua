vim.o.mouse = 'a'               -- Enable mouse support
vim.o.backup = false            -- Creates a backup file
vim.o.switchbuf = 'usetab'      -- Use already opened buffer
vim.o.undofile = true           -- Enable persistent undo

vim.o.timeoutlen = 300          -- Time to wait for a mapped sequence to complete (in milliseconds)
vim.o.updatetime = 250          -- Faster completion (4000ms Default)

vim.o.clipboard = 'unnamedplus' -- Sync with system clipboard

vim.o.hlsearch = true           -- Highlight previous search results
vim.o.inccommand = 'split'      -- Show live preview of substitution, as you type

vim.o.scrolloff = 4             -- Make sure there are always 2 lines below cursor
vim.o.sidescrolloff = 8         -- Make sure there are always 8 lines to the left and right of cursor

vim.o.showmode = false          -- Don't show since I use a custom status line
vim.o.termguicolors = true      -- True color support
vim.o.signcolumn = 'yes'        -- Always show the sign column
vim.o.number = true             -- Use Line Numbers
vim.o.relativenumber = true     -- Use Relative Line Numbers
vim.o.pumheight = 10            -- Max completion items
vim.o.splitbelow = true         -- Force all horizontal splits to go below current window
vim.o.splitright = true         -- Force all vertical splits to go to the right of current window
vim.o.wrap = false              -- Turn off line wrapping
vim.o.ruler = false             -- Do not show cursor position

vim.o.autoindent = true         -- Copy indent from current line when starting a new line
vim.o.expandtab = true          -- Use spaces instead of tabs
vim.o.ignorecase = true         -- Ignore case while searching
vim.o.incsearch = true          -- Ignore case in search pattern
vim.o.infercase = true          -- Infer letter cases while searching
vim.o.formatoptions = 'rqnl1j'  -- Improve comment editing
vim.o.tabstop = 2               -- Number of spaces tabs count for
vim.o.shiftwidth = 2            -- Number of spaces for indent width
vim.o.smartcase = true          -- Don't ignore case with capitals
vim.o.smartindent = true        -- Indent Automatically

vim.o.colorcolumn = '120'

-- Spelling
vim.o.spelllang = 'en'
vim.o.spelloptions = 'camel'

if vim.fn.has('nvim-0.11') == 1 then
  vim.opt.completeopt:append('fuzzy')   -- Use fuzzy matching for built-in completion
end

-- Thank you to
-- https://github.com/echasnovski/nvim/blob/a732d0a79dfb2145cb934310016cc580a18a0c8f/src/settings.lua#L26
local augroup = vim.api.nvim_create_augroup('CustomSettings', {})
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  callback = function()
    -- Don't auto-wrap comments and don't insert comment leader after hitting 'o'
    -- If don't do this on `FileType`, this keeps reappearing due to being set in
    -- filetype plugins.
    vim.cmd('setlocal formatoptions-=c formatoptions-=o')
  end,
  desc = [[Ensure proper 'formatoptions']],
})
