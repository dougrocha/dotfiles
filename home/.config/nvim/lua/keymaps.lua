local map = vim.keymap.set

map({ 'n', 'x' }, 'j', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
map({ 'n', 'x' }, 'k', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

map('x', 'p', 'P', { desc = 'Paste over selection without yanking' })

map('i', '<C-c>', '<Esc>')

map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Clear hlsearch and ESC' })

map('n', '<leader>wd', '<C-W>c', { desc = 'Delete window', remap = true })
map('n', '<leader>w-', '<C-W>s', { desc = 'Split window below', remap = true })
map('n', '<leader>w|', '<C-W>v', { desc = 'Split window right', remap = true })
map('n', '<leader>|', '<C-W>v', { desc = 'Split window right', remap = true })

map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up' })
map('n', 'n', 'nzzzv', { desc = 'Move to next search match', silent = true, noremap = true })
map('n', 'N', 'Nzzzv', { desc = 'Move to previous search match', silent = true, noremap = true })

map('x', '<', '<gv')
map('x', '>', '>gv')

map('n', '<leader>pu', '<cmd>packupdate<cr>', { desc = 'Update packages' })
map('n', '<leader>ps', '<cmd>packupdate ++lockfile<cr>', { desc = 'Sync packages to lockfile' })
