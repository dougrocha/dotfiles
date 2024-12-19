return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      'lua',
      'vimdoc',
      'rust',
    },
    highlight = { enable = true },
    indent = { enabled = true },
    incremental_selection = { enable = false },
    textobjects = { enable = false },
  },
}
