vim.opt.mouse = 'a'
vim.opt.backup = false
vim.opt.switchbuf = 'usetab'
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.writebackup = false

vim.opt.completeopt = 'menu,menuone,noselect'

vim.opt.timeoutlen = 300
vim.opt.updatetime = 50

vim.opt.clipboard = 'unnamedplus'

vim.opt.hlsearch = true
vim.opt.inccommand = 'split'

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.wrap = false

vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.formatoptions = 'rqnl1j'
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.infercase = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

vim.opt.colorcolumn = '120'

vim.opt.spelllang = 'en'
vim.opt.spelloptions = 'camel'

vim.g.markdown_recommended_style = 0

if vim.fn.has('nvim-0.11') == 1 then vim.opt.completeopt:append('fuzzy') end

local icons = { ERROR = ' ', WARN = ' ', HINT = '󰠠 ', INFO = ' ' }

vim.diagnostic.config({
  float = {
    source = true,
    severity_sort = true,
    prefix = function(diagnostic)
      local level = vim.diagnostic.severity[diagnostic.severity]
      local prefix = string.format(' %s ', icons[level])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
  virtual_text = {
    prefix = '',
    spacing = 2,
    format = function(diagnostic)
      local icon = icons[vim.diagnostic.severity[diagnostic.severity]]
      return string.format('%s %s ', icon, diagnostic.message)
    end,
  },
  signs = false,
})
