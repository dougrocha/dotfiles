local map = vim.keymap.set

-- Better line movement
map({ 'n', 'x' }, 'j', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
map({ 'n', 'x' }, 'k', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- Replicate <Esc>
map('i', '<C-c>', '<Esc>')

-- paste over currently selected text without yanking it
map('v', 'p', '"_dp')
-- map("v", "P", '"_dP')
map('x', '<leader>p', [["_dP]], { desc = '[P]aste from blackhole register' })
map('x', '<leader>d', [["_d]], { desc = 'Delete to blackhole register' })

-- Cancel search highlighting with ESC
map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Clear hlsearch and ESC' })

-- Windows Keymaps
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window', remap = true })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window', remap = true })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window', remap = true })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window', remap = true })
map('n', '<leader>wd', '<C-W>c', { desc = 'Delete window', remap = true })
map('n', '<leader>w-', '<C-W>s', { desc = 'Split window below', remap = true })
map('n', '<leader>w|', '<C-W>v', { desc = 'Split window right', remap = true })
map('n', '<leader>|', '<C-W>v', { desc = 'Split window right', remap = true })

-- Center screen when jumping
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up' })
map('n', 'n', 'nzz', { desc = 'Move to next search match', silent = true, noremap = true })
map('n', 'N', 'Nzz', { desc = 'Move to previous search match', silent = true, noremap = true })

-- Move Lines
map('n', '<C-Up>', '<cmd>resize +6<cr>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize 2<cr>', { desc = 'Decrease window height' })
map('n', '<C-Left>', '<cmd>vertical resize 2<cr>', { desc = 'Decrease window width' })
map('n', '<C-Right>', '<cmd>vertical resize +6<cr>', { desc = 'Increase window width' })

-- Better indenting
map('v', '<', '<gv')
map('v', '>', '>gv')
