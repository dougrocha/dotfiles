-----------------------------------------------------------
-- Color schemes configuration file
-----------------------------------------------------------

-- See: https://github.com/brainfucksec/neovim-lua#appearance

-- vim.cmd[[colorscheme nightfly]]
vim.cmd [[colorscheme tokyonight]]

vim.g.tokyonight_style = "storm"

-- Load nvim color scheme:
-- Change the "require" values with your color scheme
-- Available color schemes: nightfly
local status_ok, color_scheme = pcall(require, 'nightfly')
if not status_ok then
    return
end
