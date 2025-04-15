local minifiles_toggle = function(...)
  if not MiniFiles.close() then MiniFiles.open(...) end
end

return {
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  version = false,
  keys = {
    {
      '<leader>fo',
      minifiles_toggle,
      desc = 'Open file diretory',
    },
  },
  config = function()
    local gen_ai_spec = require('mini.extra').gen_ai_spec

    require('mini.ai').setup({
      n_lines = 500,
      custom_textobjects = {
        g = gen_ai_spec.buffer(),
        e = { -- Word with case
          { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
          '^().*()$',
        },
        t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
      },
      search_method = 'cover',
    })

    require('mini.align').setup()
    require('mini.surround').setup()
    require('mini.move').setup()
    require('mini.icons').setup({
      filetype = { astro = { glyph = '' } },
    })
    require('mini.statusline').setup()
    require('mini.splitjoin').setup()
    require('mini.bracketed').setup()

    local highlighters = {}
    for _, word in ipairs({ 'todo', 'note', 'hack' }) do
      highlighters[word] = {
        pattern = string.format('%%f[%%w]()%s()%%f[%%W]', word:upper()),
        group = string.format('MiniHipatterns%s', word:sub(1, 1):upper() .. word:sub(2)),
      }
    end
    require('mini.hipatterns').setup({
      highlighters = highlighters,
    })
  end,
}
