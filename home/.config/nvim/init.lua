vim.loader.enable()

vim.cmd.colorscheme 'doug'

require 'options'
require 'keymaps'
require 'commands'
require 'autocmds'
require 'statusline'
require 'winbar'
require 'marks'
require 'lsp'

vim.cmd.packadd 'nvim.undotree'
vim.cmd.packadd 'nvim.difftool'

require('vim._core.ui2').enable {}
