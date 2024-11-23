return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    require('mini.ai').setup()
    require('mini.surround').setup()
    require('mini.statusline').setup()
    require('mini.icons').setup({
      filetype = { astro = { glyph = '' } },
    })
    require('mini.bracketed').setup()
    require('mini.completion').setup({
      lsp_completion = {
        source_func = 'omnifunc',
        auto_setup = false,
      },
    })
    require('mini.notify').setup({
      window = {
        config = function()
          local has_statusline = vim.o.laststatus > 0
          local pad = vim.o.cmdheight + (has_statusline and 1 or 0)
          return { anchor = 'SE', col = vim.o.columns, row = vim.o.lines - pad }
        end,
      },
    })
  end,
}
