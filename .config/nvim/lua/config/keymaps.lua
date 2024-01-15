local opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- Better Lines movement
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Windows Keymaps
map("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

map("n", "n", "nzz", { desc = "Move to next search match", silent = true, noremap = true })
map("n", "N", "Nzz", { desc = "Move to previous search match", silent = true, noremap = true })
map("n", "*", "*zz", { desc = "Move to next search match", silent = true, noremap = true })
map("n", "#", "#zz", { desc = "Move to previous search match", silent = true, noremap = true })
map("n", "g*", "g*zz", { desc = "Move to next search match", silent = true, noremap = true })
map("n", "g#", "g#zz", { desc = "Move to previous search match", silent = true, noremap = true })

-- Move Lines
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all", silent = true })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down", silent = true })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up", silent = true })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down", silent = true })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up", silent = true })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down", silent = true })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up", silent = true })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
