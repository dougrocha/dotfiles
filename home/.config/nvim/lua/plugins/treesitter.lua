return {
  'nvim-treesitter/nvim-treesitter',
  version = false,
  event = 'VeryLazy',
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      'lua',
      'markdown',
      'markdown_inline',
      'regex',
      'rust',
      'toml',
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
  },
  config = function(_, opts) require('nvim-treesitter.configs').setup(opts) end,
}
