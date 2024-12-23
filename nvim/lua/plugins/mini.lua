return {
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  version = false,
  config = function()
    require('mini.ai').setup()
    require('mini.surround').setup()
    require('mini.move').setup()
    require('mini.icons').setup({
      filetype = { astro = { glyph = '' } },
    })
    require('mini.bracketed').setup()
    require('mini.statuslines').setup()
  end,
}
