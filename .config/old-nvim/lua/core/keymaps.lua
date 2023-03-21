-- Change leader to a comma
-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.g.mapleader = ' '

-----------------------------------------------------------
-- Neovim shortcuts
-----------------------------------------------------------

-- Disable arrow keys
map('', '<up>', '<nop>')
map('', '<down>', '<nop>')
map('', '<left>', '<nop>')
map('', '<right>', '<nop>')

-- Delete a word backwords
map('n', 'dw', 'vb"_d')

-- Select all
map('n', '<C-a>', 'gg<S-v>G', { noremap = false })

-- Map Esc to kk
map('i', 'kk', '<Esc>')

-- Move around splits using Ctrl + {h,j,k,l}
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Split window
map('n', 'ss', ':split<Return><C-w>w', { noremap = false })
map('n', 'sv', ':vsplit<Return><C-w>w', { noremap = false })

-- Change split orientation
map('n', '<leader>tk', '<C-w>t<C-w>K') -- change vertical to horizontal
map('n', '<leader>th', '<C-w>t<C-w>H') -- change horizontal to vertical

-- Fast saving with Ctrl and s
map('n', '<C-s>', ':w<CR>')
map('i', '<C-s>', '<C-c>:w<CR>')

map('i', '<C-Space>', '<C-c>:w<CR>')

-----------------------------------------------------------
-- Applications and Plugins shortcuts
-----------------------------------------------------------

map('n', '<F5>', ':UndotreeToggle<CR>')

-- Telescope
map('n', ';f', ':Telescope find_files<CR>')
map('n', ';r', ':Telescope live_grep<CR>')
map('n', '\\', ':Telescope buffers<CR>')
map('n', ';t', ':Telescope help_tags<CR>')
map('n', ';;', ':Telescope resume<CR>')
map('n', ';e', ':Telescope diagnostics<CR>')

-- Lspsaga
map('n', '<leader>vf', ':Lspsaga lsp_finder<CR>')
map('n', 'K', ':Lspsaga hover_doc<CR>')
map('n', '<leader>vi', ':Lspsaga implement<CR>')
map('n', '<leader>vca', ':Lspsaga code_action<CR>')
map('v', '<leader>vra', ':Lspsaga range_code_action<CR>')
map('n', '<leader>vsh', ':Lspsaga signature_help<CR>')
map('n', '<leader>vsd', ':Lspsaga show_line_diagnostics<CR>')
map('n', '[e', ':Lspsaga diagnostic_jump_next<CR>')
map('n', ']e', ':Lspsaga diagnostic_jump_prev<CR>')
map('n', '<leader>vrn', ':Lspsaga rename<CR>')

map('n', '<leader>vto', ':Lspsaga open_floaterm<CR>')
map('n', '<leader>vtc', ':Lspsaga close_floaterm<CR>')
