local map = vim.keymap

-- Better Lines movement
map.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Windows Keymaps
map.set("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
map.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
map.set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map.set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

map.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

map.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

map.set("n", "<C-a>", "ggVG", { desc = "Select all", silent = true })
