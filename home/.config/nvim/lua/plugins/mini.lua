return {
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  version = false,
  config = function()
    require('mini.ai').setup()
    require('mini.align').setup()
    require('mini.surround').setup()
    require('mini.move').setup()
    require('mini.icons').setup({
      filetype = { astro = { glyph = '' } },
    })
    require('mini.statusline').setup()
    require('mini.bracketed').setup()
  end,
}
